{ config, pkgs, lib, ... }:

let
  qt5ctColors = "/home/nixuser/.config/qt5ct/colors/noctalia.conf";
  qt6ctColors = "/home/nixuser/.config/qt6ct/colors/noctalia.conf";
  qtctConf = colorsPath: ''
    [Appearance]
    color_scheme_path=${colorsPath}
    custom_palette=true
    icon_theme=breeze-dark
    style=Fusion

    [Fonts]
    general="JetBrainsMono Nerd Font,10"
    fixed="JetBrainsMono Nerd Font,10"
  '';
in
{
  home.packages = [
    pkgs.dejavu_fonts
  ];

  fonts.fontconfig.enable = true;

  gtk.font = {
    name = "JetBrainsMono Nerd Font";
    size = 10;
  };
  

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 15;
    gtk.enable = true;
    x11.enable = true;
  };

  # qt5ct/qt6ct don't have their own Noctalia-managed config file - only the
  # color scheme (colors/noctalia.conf) is templated by Noctalia's "qt"
  # builtin. This points qt5ct/qt6ct at that generated palette.
  xdg.configFile = {
    "qt5ct/qt5ct.conf".text = qtctConf qt5ctColors;
    "qt6ct/qt6ct.conf".text = qtctConf qt6ctColors;
  };
}
