{ extraArgs }:
{ config, lib, pkgs, ... }:
with lib; {
  imports = import ./module-list.nix;

  options = {
    packages = mkOption {
      type = with types; listOf package;
      default = [ ];
    };

    formatter = mkOption {
      type = with types; package;
      default = pkgs.nixpkgs-fmt;
    };
  };

  config._module = {
    args = extraArgs;
  };
}
