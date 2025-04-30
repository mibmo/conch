{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  cfg = config.nixpkgs;

  inherit (lib) types;
  inherit (lib.options) literalExpression mergeOneOption mkOption;
  inherit (lib.trivial) isFunction;
  inherit (lib.types) mkOptionType;

  # lifted from nixos; https://github.com/NixOS/nixpkgs/blob/46e634be05ce9dc6d4db8e664515ba10b78151ae/nixos/modules/misc/nixpkgs.nix

  isConfig = x: builtins.isAttrs x || lib.isFunction x;

  optCall = f: x: if lib.isFunction f then f x else f;

  mergeConfig =
    lhs_: rhs_:
    let
      lhs = optCall lhs_ { inherit pkgs; };
      rhs = optCall rhs_ { inherit pkgs; };
    in
    lib.recursiveUpdate lhs rhs
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

  overlayType = mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = isFunction;
    merge = mergeOneOption;
  };
in
{
  options.nixpkgs = {
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
      type = with types; listOf overlayType;
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
  };

  config._module.args.pkgs = import inputs.nixpkgs {
    inherit system;
    inherit (cfg) config overlays;
  };
}
