{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.operations.nixops;
in
{
  options.operations.nixops = {
    enable = mkEnableOption "nixops";
    unstable = mkOption {
      type = types.bool;
      description = lib.mdDoc "Whether to use unstable Nixops or not.";
      default = false;
    };
    package = mkOption {
      type = types.package;
      description = lib.mdDoc ''
        Which Nixops package to use.
        Overrides `operations.nixops.unstable`
      '';
      default = if !cfg.unstable then pkgs.nixops else pkgs.nixopsUnstable;
      defaultText = "`pkgs.nixops` if not unstable, `pkgs.nixopsUnstable` if unstable";
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ];
  };
}
