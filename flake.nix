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
    let
      internals = import ./internals.nix;
      inherit (internals) fold;
    in
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
        rec {
          formatter = pkgs.nixpkgs-fmt;
          packages = import ./shells { inherit pkgs conch-lib; };

          devShells.default = packages.nix.overrideConfig {
            motd = "Thank you for contributing to Conch! 🐚";
          };
        };
      flake.load = systems: mkConfig:
        let
          fields = [ "devShells" "formatter" ];

          mkSystem = system:
            let
              pkgs = import inputs.nixpkgs { inherit system; };
              config = mkConfig { inherit pkgs; };
            in
            self.packages.${system}.${config.shell}.run config;
        in
        fold fields mkSystem systems;
    };
}
