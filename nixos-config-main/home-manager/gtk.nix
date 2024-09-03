{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerdfonts
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgs.twemoji-color-font
    pkgs.noto-fonts-emoji
  ];

  gtk = {
    enable = true;
    # font = {
    #   name = "JetBrainsMono Nerd Font";
    #   size = 12;
    # };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "lavender";
      };
    };
    # theme = {
    #   name = "Catppuccin-Mocha-Compact-Lavender-Dark";
    #   package = pkgs.catppuccin-gtk.override {
    #     accents = [ "lavender" ];
    #     size = "compact";
    #     # tweaks = [ "rimless" ];
    #     variant = "mocha";
    #   };
    # };
    # theme = {
    #   name = "Breeze-Dark";
    #   package = pkgs.libsForQt5.breeze-gtk;
    # };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      #size = 22;
    };
  # };
  
  # home.pointerCursor = {
  #   name = "Nordzy-cursors";
  #   package = pkgs.nordzy-cursor-theme;
  #   #size = 22;
  };
}
