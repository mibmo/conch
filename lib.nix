{ pkgs, ... }:
let
  mkBase = { pname, ... }: {
    name = "conch-${pname}";
    shellHook = ''
      echo "test! you've entered the conch-${pname} shell"
    '';
  };
  mkConch = args:
    let
      shellArgs = (mkBase args) // args;
    in
    pkgs.mkShell shellArgs;

  mkConfigable =
    shell: shell // {
      overrideConfig = config: shell.overrideAttrs (final: prev: {
        name = config.name or prev.name;
        buildInputs = prev.buildInputs ++ config.packages or [ ];
      });
    };

  mkRunnable =
    let
      system = pkgs.system;
    in
    shell: shell // {
      run = config: {
        formatter.${system} = config.formatter or pkgs.nixpkgs-fmt;
        devShells.${system}.default = shell.overrideConfig config;
      };
    };

  callPackage = pkgs.lib.callPackageWith (pkgs // lib);
  callShell = shell: args: mkRunnable (mkConfigable (callPackage shell args));

  lib = {
    inherit mkBase mkConch callShell;
  };
in
lib
