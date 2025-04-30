{ inputs, ... }:
let
  nixpkgs-lib = import inputs.nixpkgs-lib;

  inherit (nixpkgs-lib) attrValues escapeShellArg makeLibraryPath;
  inherit (nixpkgs-lib.modules) evalModules;
  inherit (nixpkgs-lib.attrsets) foldlAttrs recursiveUpdate;
  inherit (nixpkgs-lib.strings) concatStringsSep;

  # combined library
  lib = recursiveUpdate nixpkgs-lib { inherit conch; };

  # exposed library functions
  conch = {
    inherit
      load
      mkFlake
      ;
  };

  load = systems: module: builtins.foldl' lib.recursiveUpdate { } (map (loadModule module) systems);

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

  mkFlake =
    inputs@{ ... }:
    let
      inherit (inputs) system pkgs;
      module = mkModule inputs;
      inherit (module) config;
    in
    {
      formatter.${system} = config.formatter;
      devShells.${system}.default = mkShell config pkgs system;
    }
    // config.flake;

  mkShell =
    config: pkgs: system:
    config.mkShell {
      packages = config.packages ++ [ config.formatter ];
      LD_LIBRARY_PATH = makeLibraryPath config.libraries;
      inputsFrom = attrValues (config.flake.packages.${system} or { });
      shellHook =
        let
          aliasCmd = foldlAttrs (
            acc: name: value:
            acc + ''alias ${escapeShellArg name}=${escapeShellArg value};''
          ) "" config.aliases;
          envCmd = foldlAttrs (
            acc: name: value:
            acc + ''export ${escapeShellArg name}=${escapeShellArg value};''
          ) "" config.environment;
        in
        concatStringsSep "\n" (
          [
            aliasCmd
            envCmd
          ]
          ++ config.shellHooks
          ++ [ config.shellHook ]
        );
    };

  mkModule =
    { extraArgs, userModule, ... }:
    let
      toplevel = import ../modules/top-level.nix { inherit extraArgs; };
    in
    evalModules {
      modules = [
        toplevel
        userModule
      ];
    };
in
lib
