{ config, pkgs, inputs, myOptions, ... }:

{
  stylix = {
    targets = {
      kitty.enable = true;
      hyprland.enable = false;
      mako.enable = true;
      swaylock.enable = false;
      waybar.enable = false;
      kde.enable = false;
    };
  };
}