{ lib, pkgs, pkgsBundle, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgsBundle.pkgs-old.nerdfonts
    (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgsBundle.pkgs-old.twemoji-color-font

    pkgs.libsForQt5.qt5ct
    pkgs.qt6ct
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.breeze-icons
    pkgs.kdePackages.breeze.qt5
    pkgs.kdePackages.breeze
  ];  

  dconf.enable = lib.mkForce true;

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