{ extraArgs }:
{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkOption mdDoc literalExpression;
in
{
  imports = import ./module-list.nix;

  options = {
    packages = mkOption {
      type = with types; listOf package;
      default = [ ];
    };

    libraries = mkOption {
      type = with types; listOf package;
      default = [ ];
    };

    formatter = mkOption {
      type = with types; package;
      default = pkgs.nixfmt-tree;
      description = mdDoc ''
        Package to use for formatting Nix code with `nix fmt`.
        Also available in environment (as if it were added to the packages option)
      '';
    };

    aliases = mkOption {
      type = with types; attrs;
      default = { };
      description = mdDoc ''
        Attribute set that maps alias names to definitions
        that are then added to the shell.
      '';
    };

    environment = mkOption {
      type = with types; attrs;
      default = { };
      description = mdDoc ''
        Environment variables to set.
      '';
      example = literalExpression ''
        {
          run = "npm run start";
          build = "npm run build";
          ZEPHYR_SDK = pkgs.zephyr_sdk;
        }
      '';
    };

    # Note: should not be used by modules, only end users. Use `shellHooks` instead
    shellHook = mkOption {
      type = with types; lines;
      default = "";
      description = mdDoc ''
        Shell script that runs after all other initialisation, including those in shellHooks.
      '';
    };

    shellHooks = mkOption {
      type = with types; listOf lines;
      default = [ ];
      example = [ "touch target/{debug,release}/*" ];
      description = mdDoc ''
        Snippets of shell code to execute when shell runs.
        To change ordering, use nixpkgs' `lib.mk{Before,After,Order}`.
        This is mainly for conch modules; shellHook should generally be used instead.
      '';
    };

    mkShell = mkOption {
      # can't represent `f :: set -> drv` with option type system
      type = with types; anything;
      default = pkgs.mkShell;
      example = [ "craneLib.devShell" ];
      description = mdDoc ''
        A function compatible with `pkgs.mkShell`, to allow arbitrary extending of use-case.

        Specifically made for crane's `craneLib.devShell`.
      '';
    };
  };

  config._module = {
    args = extraArgs;
  };
}
