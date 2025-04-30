{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.node;
in
{
  imports = [
    ./npm.nix
    ./pnpm.nix
    ./yarn.nix
  ];

  options.development.node = {
    enable = mkEnableOption "node toolchain";
    package = mkOption {
      type = types.package;
      default = pkgs.nodejs;
      defaultText = literalExpression "pkgs.nodejs";
      description = lib.mdDoc ''
        Node package to use. Typical values are pkgs.nodejs or pkgs.nodejs-slim-16_x
      '';
    };
    extraPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = lib.mdDoc ''
        Extra node packages to add, such as pkgs.nodePackages.webpack-cli
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ] ++ cfg.extraPackages;
  };
}
