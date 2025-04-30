{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.node.yarn;
in
{
  options.development.node.yarn = {
    enable = mkEnableOption "yarn package manager";
    package = mkOption {
      type = types.package;
      default = pkgs.nodePackages.yarn;
      defaultText = literalExpression "pkgs.nodePackages.yarn";
      description = lib.mdDoc ''
        yarn package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
