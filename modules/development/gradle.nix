{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.gradle;
in
{
  options.development.gradle = {
    enable = mkEnableOption "gradle";
    package = mkOption {
      type = types.package;
      default = pkgs.gradle;
      defaultText = literalExpression "pkgs.gradle";
      description = lib.mdDoc ''
        Gradle package.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
