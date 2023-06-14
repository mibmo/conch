{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    let
      internals = import ./internals.nix;
      inherit (internals) mergeFields joinAttrs fold;

      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    rec {
      lib = import ./lib.nix;
      load = systems: module:
        let
          fields = [ "devShells" ];

          mkSystem = system:
            let
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [
                  inputs.fenix.overlays.default
                ];
              };
              conch-lib = lib { inherit pkgs; };
            in
            conch-lib.mkFlake {
              userModule = module;
              args = { inherit pkgs; };
            };
        in
        fold fields mkSystem systems;
    } //
    fold [ "formatter" ]
      (system: {
        formatter = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      })
      systems;
}
