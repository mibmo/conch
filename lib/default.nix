{ inputs, ... }:
let
  nixpkgs-lib = import inputs.nixpkgs-lib;

  inherit (builtins) typeOf;
  inherit (nixpkgs-lib) attrValues escapeShellArg makeLibraryPath;
  inherit (nixpkgs-lib.modules) evalModules;
  inherit (nixpkgs-lib.attrsets) foldlAttrs recursiveUpdate;
  inherit (nixpkgs-lib.strings) concatStringsSep;

  # combined library
  lib = recursiveUpdate nixpkgs-lib { inherit conch; };

  # exposed library functions
  conch = {
    inherit
      defaultSystems
      load
      loadForSystems
      mkFlake
      ;
  };

  # default set of systems to configure conch for.
  # should generally cover as many standard systems as possible, hence using `flakeExposed`
  defaultSystems = nixpkgs-lib.systems.flakeExposed;

  # load conch. the main entrypoint
  load = arg: if typeOf arg == "list" then loadForSystems arg else loadForSystems defaultSystems arg;

  # load conch for a specific set of systems.
  loadForSystems =
    systems: module: builtins.foldl' lib.recursiveUpdate { } (map (loadModule module) systems);

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
      extraArgs = { inherit inputs system; };
    };

  mkFlake =
    args@{ ... }:
    let
      inherit (args) system pkgs;
      module = mkModule args;
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
    { userModule, system, ... }:
    evalModules {
      modules = import ../modules/module-list.nix ++ [ userModule ];
      specialArgs = { inherit inputs system; };
    };
in
lib
