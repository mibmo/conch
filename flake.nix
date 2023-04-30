{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.fenix.overlays.default
            ];
          };
          conch-lib = import ./lib.nix { inherit pkgs; };
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          packages = import ./shells { inherit pkgs conch-lib; };
        };
      flake.loadShell = system: shell:
        self.packages.${system}.${shell}.run system;
    };
}
