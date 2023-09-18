{ nixpkgs-lib }:
let
  inherit (nixpkgs-lib) escapeShellArg makeLibraryPath;
  inherit (nixpkgs-lib.modules) evalModules;
  inherit (nixpkgs-lib.attrsets) foldlAttrs;

  mkFlake = inputs@{ ... }:
    let
      inherit (inputs) system pkgs;
      module = mkModule inputs;
      inherit (module) config;
    in
    {
      formatter.${system} = config.formatter;
      devShells.${system}.default = mkShell config pkgs;
    } // config.flake;

  mkShell = config: pkgs:
    let
      aliasCmd = foldlAttrs (acc: name: value: acc + ''alias ${escapeShellArg name}=${escapeShellArg value};'') "" config.aliases;
      envCmd = foldlAttrs (acc: name: value: acc + ''export ${escapeShellArg name}=${escapeShellArg value};'') "" config.environment;
    in
    pkgs.mkShell {
      inherit (config) packages;
      LD_LIBRARY_PATH = makeLibraryPath config.libraries;
      shellHook = aliasCmd + envCmd;
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
