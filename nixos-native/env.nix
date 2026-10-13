{ config, pkgs, lib, myOptions, ... }: {

  environment.variables = {
    EDITOR = "code";
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    # GSETTINGS_BACKEND = "keyfile"; # was forcing gsettings/portal reads off dconf, breaking dark mode
    LIBSEAT_BACKEND = "seatd";
    WAYLAND_DISPLAY = "wayland-1";
    # QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # TODO
  # nix.extraOptions = ''
  #   access-tokens = github.com=${builtins.readFile /path/to/token/file}
  # '';
  # nix.settings.access-tokens = { "github.com" = "ghp_xxxxxxxx"; };
  
  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    silent = false;
    loadInNixShell = true;
    direnvrcExtra = "";
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
}