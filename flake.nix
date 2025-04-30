{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{ ... }:
    let
      lib = import ./lib { inherit inputs; };

      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      loadModule =
        module: system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ ];
          };
        in
        lib.conch.mkFlake {
          inherit system pkgs;
          userModule = module;
          extraArgs = { inherit pkgs inputs system; };
        };

      # @todo: migrate to lib.recursiveUpdate
      # also nixpkgs' lib is available through nixpkgs.lib; there's no need to import it
      load = systems: module: builtins.foldl' lib.recursiveUpdate { } (map (loadModule module) systems);
    in
    #load = systems: module: fold [ "devShell" "formatter" ] (loadModule module) systems;
    {
      inherit load;
    }
    // load systems ({ pkgs, system, ... }: { });
}
