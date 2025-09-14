{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkOption
    types
    ;
in
{
  options.shell = {
    aliases = mkOption {
      type = with types; attrs;
      default = { };
      description = ''
        Attribute set that maps alias names to definitions
        that are then added to the shell.
      '';
    };

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
      description = ''
        Package to use for formatting Nix code with `nix fmt`.
        Also available in environment (as if it were added to the packages option)
      '';
    };

    environment = mkOption {
      type = with types; attrs;
      default = { };
      description = ''
        Environment variables to set.
      '';
      example = {
        run = "npm run start";
        build = "npm run build";
        ZEPHYR_SDK = pkgs.zephyr_sdk;
      };
    };

    # Note: should not be used by modules, only end users. Use `hooks` instead
    hook = mkOption {
      type = with types; lines;
      default = "";
      description = ''
        Shell script that runs after all other initialisation, including those in `shell.hooks`.
      '';
    };

    hooks = mkOption {
      type = with types; listOf lines;
      default = [ ];
      example = [ "touch target/{debug,release}/*" ];
      description = ''
        Snippets of shell code to execute when shell runs.
        To change ordering, use nixpkgs' `lib.mk{Before,After,Order}`.
        This is generally for conch modules; use `shell.hook` if an end user.
      '';
    };

    mkShell = mkOption {
      type = with types; anything;
      default = pkgs.mkShell;
      example = literalExpression "craneLib.devShell";
      description = ''
        A function compatible with `pkgs.mkShell`, to allow arbitrary extending of use-case.

        Specifically made for crane's `craneLib.devShell`.
      '';
    };
  };
}
