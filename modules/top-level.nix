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
      default = pkgs.nixpkgs-fmt;
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
  };

  config._module = {
    args = extraArgs;
  };
}
