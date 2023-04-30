{ pkgs, conch-lib }:
let
  /*
    callPackage = pkgs.lib.callPackageWith (pkgs // conch-lib);
    callShell = shell: args: (callPackage shell args);
  */
  inherit (conch-lib) mkConch callShell;
  shells = rec {
    default = mkConch { pname = "base"; };
    go = callShell ./go.nix { };
    rust = callShell ./rust.nix { };
  };
in
shells
