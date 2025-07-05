{ lib, pkgs, pkgsBundle, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgsBundle.pkgs-old.nerdfonts
    (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgsBundle.pkgs-old.twemoji-color-font

    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.breeze-icons
    pkgs.kdePackages.breeze.qt5
    pkgs.kdePackages.breeze
  ];  

  

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