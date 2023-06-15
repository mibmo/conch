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

  mkShell = config: pkgs.mkShell {
    inherit (config) packages;
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
