{ pkgs, conch-lib }:
let
  inherit (conch-lib) mkConch callShell;

  shells = rec {
    base = callShell ./base.nix { };
    go = callShell ./go.nix { };
    nix = callShell ./nix.nix { };
    rust = callShell ./rust.nix { };
  };
in
shells
