{ nixpkgs-lib }:
let
  inherit (nixpkgs-lib) attrValues escapeShellArg makeLibraryPath;
  inherit (nixpkgs-lib.modules) evalModules;
  inherit (nixpkgs-lib.attrsets) foldlAttrs;
  inherit (nixpkgs-lib.strings) concatStringsSep;

  mkFlake = inputs@{ ... }:
    let
      inherit (inputs) system pkgs;
      module = mkModule inputs;
      inherit (module) config;
    in
    {
      formatter.${system} = config.formatter;
      devShells.${system}.default = mkShell config pkgs system;
    } // config.flake;

  mkShell = config: pkgs: system:
    pkgs.mkShell {
      packages = config.packages ++ [ config.formatter ];
      LD_LIBRARY_PATH = makeLibraryPath config.libraries;
      inputsFrom = attrValues (config.flake.packages.${system} or { });
      shellHook =
        let
          aliasCmd = foldlAttrs (acc: name: value: acc + ''alias ${escapeShellArg name}=${escapeShellArg value};'') "" config.aliases;
          envCmd = foldlAttrs (acc: name: value: acc + ''export ${escapeShellArg name}=${escapeShellArg value};'') "" config.environment;
        in
        concatStringsSep "\n" ([
          aliasCmd
          envCmd
        ] ++ config.shellHooks ++ [ config.shellHook ]);
    };

  mkModule = { extraArgs, userModule, ... }:
    let
      toplevel = import ./modules/top-level.nix { inherit extraArgs; };
    in
    evalModules {
      modules = [ toplevel userModule ];
    };

  lib = {
    inherit mkFlake;
  };
in
lib
