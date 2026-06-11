{ inputs, ... }:
let
  lib = import inputs.nixpkgs-lib;

  inherit (lib.attrsets) isDerivation;
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
    derivation = mkOptionType {
      name = "derivation";
      description = "nix derivation";
      check = isDerivation;
      merge = mergeOneOption;
    };
    nixosConfiguration = mkOptionType {
      name = "nixos-configuration";
      description = "nixos configuration";
      check = x: isDerivation (x.config.system.build.toplevel or null);
      merge = mergeOneOption;
    };
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
        hydraJobs
        nixosConfigurations
        nixosModules
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
