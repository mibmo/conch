{
  conch,
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.nixpkgs;

  inherit (lib) types;
  inherit (lib.lists) any;
  inherit (lib.options) literalExpression mkOption;
  inherit (lib.strings) getName match;

  # mostly lifted from nixos; https://github.com/NixOS/nixpkgs/blob/46e634be05ce9dc6d4db8e664515ba10b78151ae/nixos/modules/misc/nixpkgs.nix
  # see comments for differences

  isConfig = x: builtins.isAttrs x || lib.isFunction x;

  optCall = f: x: if lib.isFunction f then f x else f;

  mergeConfig =
    lhs_: rhs_:
    let
      # NOTE: the difference between this and nixpkgs' implementation is that `pkgs` aren't passed here
      lhs = optCall lhs_ { inherit lib; };
      rhs = optCall rhs_ { inherit lib; };
    in
    lib.recursiveUpdate lhs rhs
    // lib.optionalAttrs (lhs ? allowUnfreePackages) {
      allowUnfreePackages = lhs.allowUnfreePackages ++ (lib.attrByPath [ "allowUnfreePackages" ] [ ] rhs);
    }
    // lib.optionalAttrs (lhs ? packageOverrides) {
      packageOverrides =
        pkgs:
        optCall lhs.packageOverrides pkgs // optCall (lib.attrByPath [ "packageOverrides" ] { } rhs) pkgs;
    }
    // lib.optionalAttrs (lhs ? perlPackageOverrides) {
      perlPackageOverrides =
        pkgs:
        optCall lhs.perlPackageOverrides pkgs
        // optCall (lib.attrByPath [ "perlPackageOverrides" ] { } rhs) pkgs;
    };

  configType = lib.mkOptionType {
    name = "nixpkgs-config";
    description = "nixpkgs config";
    check =
      x:
      let
        traceXIfNot = c: if c x then true else lib.traceSeqN 1 x false;
      in
      traceXIfNot isConfig;
    merge = args: lib.foldr (def: mergeConfig def.value) { };
  };
in
{
  options.nixpkgs = {
    final = lib.mkOption {
      type = types.attrs;
      internal = true;
      description = "Internal option used to write package set with changes applied";
      apply = conch.applySystemsWithGenerator (
        system: options: import inputs.nixpkgs (options // { inherit system; })
      );
    };

    config = lib.mkOption {
      default = { };
      example = lib.literalExpression ''
        { allowBroken = true; allowUnfree = true; }
      '';
      type = configType;
      description = ''
        Global configuration for Nixpkgs.
        The complete list of [Nixpkgs configuration options](https://nixos.org/manual/nixpkgs/unstable/#sec-config-options-reference) is in the [Nixpkgs manual section on global configuration](https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig).

        Duplicate of NixOS' `nixpkgs.config`
      '';
    };

    overlays = mkOption {
      type = with types; listOf lib.conch.types.overlay;
      default = [ ];
      example = literalExpression ''
        [
          (final: prev: {
            openssh = prev.openssh.override {
              hpnSupport = true;
              kerberos = final.libkrb5;
            };
          })
        ]
      '';
      description = ''
        List of overlays to apply to Nixpkgs.
        This option allows modifying the package set accessed through the `pkgs` module argument.

        Duplicate of NixOS' `nixpkgs.overlays`
      '';
    };

    permittedInsecurePatterns = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "python(2|27)"
      ];
      description = ''
        Regex patterns of package names that are permitted to be insecure.

        Overrides `nixpkgs.config.allowUnfreePredicate` when non-empty.
      '';
    };

    permittedUnfreePatterns = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [
        "lightburn"
        "osu-lazer(-bin)?"
      ];
      description = ''
        Regex patterns of package names that are permitted to be unfree.

        Overrides `nixpkgs.config.allowUnfreePredicate` when non-empty.
      '';
    };
  };

  config.nixpkgs = {
    final = { inherit (config.nixpkgs) config overlays; };
    config = {
      ${if cfg.permittedInsecurePatterns != [ ] then "allowInsecurePredicate" else null} =
        pkg: any (pattern: match pattern (getName pkg) != null) cfg.permittedInsecurePatterns;
      ${if cfg.permittedUnfreePatterns != [ ] then "allowUnfreePredicate" else null} =
        pkg: any (pattern: match pattern (getName pkg) != null) cfg.permittedUnfreePatterns;
    };
  };
}
