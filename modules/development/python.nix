{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.python;
in
{
  options.development.python = {
    enable = mkEnableOption "python";
    package = mkOption {
      type = types.package;
      default = pkgs.python3Full;
      defaultText = "Python 3 Full";
      description = lib.mdDoc ''
        Python package to use. Typical values are pkgs.python311 or pkgs.python310.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];
  };
}
