{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # don't break library if `nixpkgs` is overridden (as it may well be!)
    nixpkgs-lib.url = "github:nixos/nixpkgs/nixpkgs-unstable?dir=lib";
  };

  outputs =
    inputs@{ ... }:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      inherit (lib.conch) load;
      lib = lib.conch;
      templates = {
        python = {
          description = "Environment for Python development";
          path = ./templates/python;
        };
        rust = {
          description = "Environment for Rust development";
          path = ./templates/rust;
        };
      };
    };
}
