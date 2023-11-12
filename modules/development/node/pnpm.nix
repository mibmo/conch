{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.node.pnpm;
in
{
  options.development.node.pnpm = {
    enable = mkEnableOption "pnpm package manager";
    package = mkOption {
      type = types.package;
      default = pkgs.nodePackages.pnpm;
      defaultText = literalExpression "pkgs.nodePackages.pnpm";
      description = lib.mdDoc ''
        pnpm package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
