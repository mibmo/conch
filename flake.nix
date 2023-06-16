{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self, nixpkgs, ... }:
    let
      lib = import ./lib.nix;
      internals = import ./internals.nix;
      inherit (internals) mergeFields joinAttrs fold;

      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      loadModule = module: system:
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

      load = systems: module: fold [ "devShell" "formatter" ] (loadModule module) systems;
    in
    {
      inherit lib load;
    } // load systems ({ ... }: { });
}
