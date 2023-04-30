{ pkgs, ... }:
let
  mkBase = { pname, ... }: {
    shellHook = ''
      echo "test! you've entered the conch-${pname} shell"
    '';
  };
  mkConch = args:
    let
      shellHook = "";
      shellArgs = ((mkBase args) // args);
    in
    pkgs.mkShell shellArgs;

  mkRunnable =
    shell: shell // {
      run = system: {
        formatter.${system} = pkgs.nixpkgs-fmt;
        devShells.${system}.default = shell;
      };
    };

  callPackage = pkgs.lib.callPackageWith (pkgs // lib);
  callShell = shell: args: mkRunnable (callPackage shell args);

  lib = {
    inherit mkConch callShell;
  };
in
lib
