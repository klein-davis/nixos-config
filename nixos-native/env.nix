{ config, pkgs, lib, myOptions, ... }: {

  environment.variables = {
    EDITOR = "code";
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    GSETTINGS_BACKEND = "keyfile";
    LIBSEAT_BACKEND = "seatd";
    WAYLAND_DISPLAY = "wayland-1";
    # QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}