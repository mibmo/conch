{ nixpkgs-lib }:
let
  inherit (nixpkgs-lib) escapeShellArg makeLibraryPath;
  inherit (nixpkgs-lib.modules) evalModules;

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
      aliasCmds = map
        ({ name, definition }: "alias ${escapeShellArg name}=${escapeShellArg definition}")
        config.aliases;
      aliasCmd = builtins.foldl' (acc: cmd: acc + cmd) "" aliasCmds;
    in
    pkgs.mkShell {
      inherit (config) packages;
      LD_LIBRARY_PATH = makeLibraryPath config.libraries;
      shellHook = aliasCmd;
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
