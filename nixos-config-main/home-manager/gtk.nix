{ lib, pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerdfonts
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgs.twemoji-color-font
    pkgs.noto-fonts-emoji
  ];  

  

  gtk = lib.mkForce {
    enable = false;
    
    iconTheme = lib.mkForce  {
      # name = "Shades-of-gray";
      # package = pkgs.shades-of-gray-theme;
      # name = "Adwaita";
      # package = pkgs.adwaita-icon-theme; 
      name = "windows10";
      package = pkgs.windows10-icons;
      # name = "WhiteSur";
      # package = pkgs.whitesur-icon-theme;
      # name = "Gruvbox-Plus-Dark";
      # package = pkgs.gruvbox-plus-icons;  
    };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      #size = 22;
    };
    theme = lib.mkForce { # Stupid stylix
        name = "Breeze-Dark";
        package = pkgs.libsForQt5.breeze-gtk;
    };
  };
  
  home.pointerCursor = {
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
    #size = 22;
  };
}
