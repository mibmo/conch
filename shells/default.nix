{ pkgs, conch-lib }:
let
  inherit (conch-lib) mkConch callShell;

  shells = rec {
    #default = mkConch { pname = "base"; };
    go = callShell ./go.nix { };
    rust = callShell ./rust.nix { };
  };
in
shells
