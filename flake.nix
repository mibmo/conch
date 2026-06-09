{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # don't break library if `nixpkgs` is overridden (as it may well be!)
    nixpkgs-lib.url = "github:nixos/nixpkgs/nixpkgs-unstable?dir=lib";
  };

  outputs =
    inputs:
    let
      conch = import ./lib { inherit inputs; };
    in
    {
      inherit (conch) configure;
      lib = conch;
      templates = {
        default = {
          description = "Default template suitable as starting point";
          path = ./templates/default;
        };
        nixpkgs = {
          description = "Template showing nixpkgs overlay being applied";
          path = ./templates/nixpkgs;
        };
      };
    };
}
