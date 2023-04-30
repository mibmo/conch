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

  mkRunnable =
    let
      system = pkgs.system;
    in
    shell: shell // {
      run = config: {
        formatter.${system} = config.formatter or pkgs.nixpkgs-fmt;
        devShells.${system}.default = shell.overrideAttrs (final: prev: {
          nativeBuildInputs = prev.nativeBuildInputs ++ config.packages or [ ];
        });
      };
    };

  callPackage = pkgs.lib.callPackageWith (pkgs // lib);
  callShell = shell: args: mkRunnable (callPackage shell args);

  lib = {
    inherit mkBase mkConch callShell;
  };
in
lib
