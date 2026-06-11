{ inputs, ... }:
let
  lib = import inputs.nixpkgs-lib;

  # exposed library functions
  conch = {
    inherit
      configure
      setIf
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

  /*
    Set key in attribute set based on condition

    # Examples
    :::{.example}
    ```nix
    {
      ${setIf "overrides" (system == "aarch64-darwin")} = [ ... ];
    }
    ```
    :::
  */
  setIf = key: condition: if condition then key else null;
in
conch
