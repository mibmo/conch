{ config, lib, inputs, system, ... }:
with lib;
let
  cfg = config.operations.nixos-anywhere;
in
{
  options.operations.nixos-anywhere = {
    enable = mkEnableOption "nixos-anywhere";
  };

  config = mkIf cfg.enable {
    packages = [
      inputs.nixos-anywhere.packages.${system}.nixos-anywhere
    ];
  };
}
