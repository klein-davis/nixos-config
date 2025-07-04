{ config, pkgs, myOptions, ... }:
{

  environment.systemPackages = with pkgs; [
    # Themes
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    kdePackages.breeze.qt5
    kdePackages.breeze
    # catppuccin-cursors # Mouse cursor theme
    # catppuccin-papirus-folders # Icon theme, e.g. for pcmanfm-qt
    # papirus-folders # For the catppucing stuff work
  ];

  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = {
  #     name = "gtk2";
  #     package = pkgs.libsForQt5.breeze-qt5;
  #   };
  # };

}