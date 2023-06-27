{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.operations.terranix;
in
{
  options.operations.terranix = {
    enable = mkEnableOption "terranix";
    package = mkOption {
      type = types.package;
      description = lib.mdDoc "Which Nixops package to use.";
      default = pkgs.terranix;
      defaultText = literalExpression "pkgs.terranix";
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ];
  };
}
