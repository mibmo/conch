{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.bevy;
in
{
  options.development.bevy = {
    enable = mkEnableOption "bevy";
  };

  config = mkIf cfg.enable rec {
    development.rust.enable = true;
    packages = with pkgs; [
      pkg-config
      cmake
      udev
      alsa-lib
      fontconfig
      vulkan-loader
      vulkan-headers

      # xorg
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr

      # wayland
      libxkbcommon
      wayland
    ];
    libraries = packages;
  };
}
