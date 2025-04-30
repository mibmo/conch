{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.operations.morph;
in
{
  options.operations.morph = {
    enable = mkEnableOption "morph";
    package = mkOption {
      type = types.package;
      description = lib.mdDoc "Which Morph package to use.";
      default = pkgs.morph;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ];
  };
}
