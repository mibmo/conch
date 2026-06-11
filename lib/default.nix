{ inputs, ... }:
let
  lib = import inputs.nixpkgs-lib;

  inherit (lib.options) mergeOneOption;
  inherit (lib.trivial) isFunction;
  inherit (lib.types) mkOptionType;

  # exposed library functions
  conch = {
    inherit
      configure
      setIf
      types
      ;
  };

  types = {
    overlay = mkOptionType {
      name = "nixpkgs-overlay";
      description = "nixpkgs overlay";
      check = isFunction;
      merge = mergeOneOption;
    };
  };

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
      inherit (eval.config)
        checks
        devShells
        formatter
        overlays
        packages
        templates
        ;
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
