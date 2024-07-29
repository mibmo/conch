{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self, nixpkgs, ... }:
    let
      nixpkgs-lib = nixpkgs.lib;
      conch-lib = import ./lib.nix { inherit nixpkgs-lib; };

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
            overlays = [ ];
          };
        in
        conch-lib.mkFlake {
          inherit system pkgs;
          userModule = module;
          extraArgs = { inherit pkgs inputs system; };
        };

      # @todo: migrate to lib.recursiveUpdate
      # also nixpkgs' lib is available through nixpkgs.lib; there's no need to import it
      load = systems: module: builtins.foldl'
        nixpkgs-lib.recursiveUpdate
        { }
        (map (loadModule module) systems);
      #load = systems: module: fold [ "devShell" "formatter" ] (loadModule module) systems;
    in
    {
      inherit load;
      templates = builtins.mapAttrs
        (name: _: rec { path = ./templates + "/${name}"; description = (import "${path}/flake.nix").description; })
        (builtins.readDir ./templates);
    } // load systems ({ pkgs, system, ... }: { });
}
