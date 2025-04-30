{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.go;
in
{
  options.development.go = {
    enable = mkEnableOption "go toolchain";
    package = mkOption {
      type = types.package;
      default = pkgs.go;
      defaultText = literalExpression "pkgs.go";
      description = lib.mdDoc ''
        Go package to use. Typical values are pkgs.go or pkgs.go_1_19.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
