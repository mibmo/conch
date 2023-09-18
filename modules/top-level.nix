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
    };

    aliases = mkOption {
      type = with types; listOf attrs;
      default = [ ];
      description = mdDoc ''
        List of sets with form `{ name = str; definition = string; }`
        that are added to the shell as aliases.
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
