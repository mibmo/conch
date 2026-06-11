{ inputs, ... }:
let
  nixpkgs-lib = import inputs.nixpkgs-lib;

  inherit (nixpkgs-lib.attrsets) isDerivation;
  inherit (nixpkgs-lib.options) mergeOneOption;
  inherit (nixpkgs-lib.trivial) isFunction;
  inherit (nixpkgs-lib.types) mkOptionType;

  lib = nixpkgs-lib // {
    inherit conch;
  };

  # exposed library functions
  conch = {
    inherit
      configure
      setIf
      types
      ;
  };

  types = {
    app = mkOptionType {
      name = "app";
      description = "nix flake app";
      check = isDerivation;
      merge = mergeOneOption;
    };
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
        specialArgs = { inherit inputs lib; };
        modules = [
          ../modules
          module
        ];
      };
    in
    {
      inherit (eval.config)
        apps
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
