{ config, pkgs, inputs, myOptions, ... }:

{

  stylix.targets = {
    kitty.enable = false;
    hyprland.enable = false;
    mako.enable = false;
    swaylock.enable = false;
    waybar.enable = false;
    kde.enable = false;
  };
}