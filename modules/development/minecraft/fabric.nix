{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.minecraft.fabric;
in
{
  options.development.minecraft.fabric = {
    enable = mkEnableOption "fabricmc development environment";
  };

  config = mkIf cfg.enable {
    development = {
      java = {
        enable = true;
        package = pkgs.jdk17; # jdk17 is recommended for fabric
      };
      gradle.enable = true;
    };
  };
}
