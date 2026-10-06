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
  ];

  dconf.enable = lib.mkForce true;

  # Baseline only - Noctalia (see home-manager/noctalia.nix) writes this same
  # key at runtime once it applies a theme, plus gtk-theme (adw-gtk3 /
  # adw-gtk3-dark) which we deliberately don't declare here so it doesn't
  # fight Noctalia's dynamic switching. This just avoids a light flash before
  # Noctalia's first run.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = lib.mkForce null;

    # Icon theme has no Noctalia template, so it's a static pick here.
    # Name must match the actual on-disk theme dir (share/icons/breeze-dark)
    # exactly - GTK's icon theme lookup is a case-sensitive directory match,
    # so "Breeze-Dark" silently fails to resolve and falls back to hicolor.
    iconTheme = lib.mkForce {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
  };
}