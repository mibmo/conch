{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.node.npm;
in
{
  options.development.node.npm = {
    enable = mkEnableOption "npm package manager";
    package = mkOption {
      type = types.package;
      default = pkgs.nodePackages.npm;
      defaultText = literalExpression "pkgs.nodePackages.npm";
      description = lib.mdDoc ''
        npm package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
