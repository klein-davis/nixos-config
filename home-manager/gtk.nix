{ lib, pkgs, pkgsBundle, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgsBundle.pkgs-old.nerdfonts
    (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # pkgsBundle.pkgs-old.twemoji-color-font

    pkgs.libsForQt5.qt5ct
    pkgs.qt6ct
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.breeze-icons
    pkgs.kdePackages.breeze.qt5
    pkgs.kdePackages.breeze

    # For compatability
    pkgs.adwaita-icon-theme
    # pkgs.gnome-themes-standard
  ];  

  dconf.enable = lib.mkForce true;

  # xdg.configFile = {
  #   # 1. Main Kvantum configuration file, pointing to your theme
  #   "Kvantum/kvantum.kvconfig".text = ''
  #     [General]
  #     # The 'theme' option tells Kvantum which theme to load
  #     theme=${kvantumThemeName}
  #     # Other general Kvantum settings can go here if needed
  #     # e.g., animations, translucency settings
  #   '';

  # };

  gtk = {
    enable = true;
    
    iconTheme = lib.mkForce  {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-icons;
    }; 

    theme = lib.mkForce { # Stupid stylix
        name = "Breeze-Dark";
        # package = pkgs.libsForQt5.breeze-gtk;
        package = pkgs.kdePackages.breeze-gtk;
    };
  };
}