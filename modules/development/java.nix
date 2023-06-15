{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.java;
in
{
  options.development.java = {
    enable = mkEnableOption "java toolchain";
    package = mkOption {
      type = types.package;
      default = pkgs.jdk;
      defaultText = literalExpression "pkgs.jdk";
      description = lib.mdDoc ''
        Java package to use. Typical values are pkgs.jdk or pkgs.jre.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
