{ lib, pkgs, pkgsBundle, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgsBundle.pkgs-old.nerdfonts
    (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgsBundle.pkgs-old.twemoji-color-font
    pkgsBundle.pkgs-old.noto-fonts-emoji
  ];  

  

  gtk = {
    enable = true;
    
    iconTheme = lib.mkForce  {
      # name = "Shades-of-gray";
      # package = pkgs.shades-of-gray-theme;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme; 
      # name = "windows10";
      # package = pkgs.windows10-icons;
      # name = "WhiteSur";
      # package = pkgs.whitesur-icon-theme;
      # name = "Gruvbox-Plus-Dark";
      # package = pkgs.gruvbox-plus-icons;  
    };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 22;
    };

    theme = {
      name = "Catppuccin-Macchiato-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "macchiato";
      };
    };

    # theme = lib.mkForce { # Stupid stylix
    #     name = "Breeze-Dark";
    #     package = pkgs.libsForQt5.breeze-gtk;
    # };
  };
  
  home.pointerCursor = {
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
    #size = 22;
  };
}
