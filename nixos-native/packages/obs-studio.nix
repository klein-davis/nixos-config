{ config, pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-source-clone
      obs-move-transition
      advanced-scene-switcher
      obs-source-clone
      obs-composite-blur
      obs-pipewire-audio-capture
      obs-multi-rtmp
    ];
  };

  # For virtual camera
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
}