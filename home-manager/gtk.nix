{ lib, pkgs, pkgsBundle, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.libsForQt5.qt5ct
    pkgs.qt6Packages.qt6ct
    pkgs.kdePackages.breeze-icons
    pkgs.adw-gtk3 # base GTK theme Noctalia switches between light/dark at runtime
    pkgsBundle.pkgs-old.nerdfonts
    (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgs.gsettings-desktop-schemas
  ];

  dconf.enable = lib.mkForce true;
  # For noctalia
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = lib.mkForce null;
    iconTheme = lib.mkForce {
      # theme dir share/icons/breeze-dark case sensitive
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
  };
}