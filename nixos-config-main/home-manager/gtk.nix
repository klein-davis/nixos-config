{ lib, pkgs, pkgsBundle, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgsBundle.pkgs-old.nerdfonts
    (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgsBundle.pkgs-old.twemoji-color-font
    # pkgsBundle.pkgs-old.noto-fonts-emoji
    # pkgs.windows10-icons
    # pkgs.whitesur-icon-theme
    # pkgs.kdePackages.breeze
    # pkgs.kdePackages.breeze-icons
    pkgs.kdePackages.breeze-gtk
    pkgs.whitesur-icon-theme
  ];  

  

  gtk = {
    enable = true;
    
    iconTheme = lib.mkForce  {
      # name = "Shades-of-gray";
      # package = pkgs.shades-of-gray-theme;
      # name = "Adwaita";
      # package = pkgs.adwaita-icon-theme; 
      # name = "windows10";
      # package = pkgs.windows10-icons;
      # name = "WhiteSur";
      # package = pkgs.whitesur-icon-theme;
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-icons;
      # name = "Gruvbox-Plus-Dark";
      # package = pkgs.gruvbox-plus-icons;  
    }; 
    # cursorTheme = {
    #   name = "Nordzy-cursors";
    #   package = pkgs.nordzy-cursor-theme;
    #   size = 22;
    # };

  #   # theme = {
  #   #   name = "Catppuccin-Macchiato-Compact-Pink-Dark";
  #   #   package = pkgs.catppuccin-gtk.override {
  #   #     accents = [ "pink" ];
  #   #     size = "compact";
  #   #     tweaks = [ "rimless" "black" ];
  #   #     variant = "macchiato";
  #   #   };
  #   # };

  #   theme = lib.mkForce { # Stupid stylix
  #       name = "Breeze-Dark";
  #       # package = pkgs.libsForQt5.breeze-gtk;
  #       package = pkgs.kdePackages.breeze-gtk;
  #   };
  };

  # dconf.settings."org/gnome/desktop/interface" = {
  #   gtk-theme = lib.mkForce "Breeze-Dark";
  #   color-scheme = "prefer-dark";
  # };
  
  # home.pointerCursor = {
  #   name = "Nordzy-cursors";
  #   package = pkgs.nordzy-cursor-theme;
  #   #size = 22;
  # };
}

# { lib, pkgs, pkgsBundle, ... }:


# {
#   home.sessionVariables.GTK_THEME = lib.mkForce  "Catppuccin-Macchiato-Compact-Pink-Dark";
#   gtk =  {
#     enable = true;
#     theme = {
#       name = "Catppuccin-Macchiato-Compact-Pink-Dark";
#       package = pkgs.catppuccin-gtk.override {
#         accents = [ "pink" ];
#         size = "compact";
#         tweaks = [ "rimless" "black" ];
#         variant = "macchiato";
#       };
#     };
#     iconTheme = {
#       name = "colloid-icon-theme";
#       package = pkgs.colloid-icon-theme;
#     };
#     gtk3.extraConfig = {
#       Settings = ''
#         gtk-application-prefer-dark-theme=1
#       '';
#     };

#     gtk4.extraConfig = {
#       Settings = ''
#         gtk-application-prefer-dark-theme=1
#       '';
#     };
#   };
# }                         