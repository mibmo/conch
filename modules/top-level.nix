{ extraArgs }:
{ config, lib, pkgs, ... }:
with lib; {
  imports = import ./module-list.nix;

  options = {
    packages = mkOption {
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
  };

  config._module = {
    args = extraArgs;
  };
}
