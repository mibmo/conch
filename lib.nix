{ pkgs, ... }:
let
  mkFlake = inputs @ { ... }:
    let
      module = mkModule inputs;
      inherit (module) config;
    in
    {
      inherit (config) formatter;
      devShell = mkShell config;
    };

  mkShell = config:
    let
      inherit (pkgs.lib) escapeShellArg;
      aliasCmds = map
        ({ name, definition }: "alias ${escapeShellArg name}=${escapeShellArg definition}")
        config.aliases;
      aliasCmd = builtins.foldl' (acc: cmd: acc + cmd) "" aliasCmds;
    in
    pkgs.mkShell {
      inherit (config) packages;
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath config.libraries;
      shellHook = ''
        echo "hello! :D"
      '' + aliasCmd;
    };

  mkModule = { args, userModule }:
    let
      toplevel = import ./modules/top-level.nix { inherit extraArgs; };
      extraArgs = args // { inherit pkgs; };
    in
    pkgs.lib.evalModules {
      modules = [ toplevel userModule ];
    };

  lib = {
    inherit mkFlake;
  };
in
lib
