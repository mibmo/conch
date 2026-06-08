{ inputs, ... }:
let
  lib = import inputs.nixpkgs-lib;

  # exposed library functions
  conch = {
    inherit
      configure
      types
      ;
  };

  types = import ./types.nix;

  configure =
    module:
    let
      eval = lib.modules.evalModules {
        specialArgs = { inherit inputs; };
        modules = [
          ../modules
          module
        ];
      };
    in
    {
      inherit (eval.config) packages devShells formatter;
    };
in
conch
