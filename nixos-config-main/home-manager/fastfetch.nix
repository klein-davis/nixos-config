{ config, pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetch;

    # Define your fastfetch configuration here
    settings = {
      # This directly maps to the content of ~/.config/fastfetch/config.jsonc
      logo = {
        type = "builtin";
        source = "nixos"; # Example: Use the NixOS logo
        # You can adjust padding, colors, etc. here as attributes
        padding = {
          left = 2;
          right = 4;
        };
        color = {
          "1" = "blue";
          "2" = "blue";
        };
      };
      display = {
        separator = " => ";
        color = {
          keys = "yellow";
          title = "magenta";
        };
        key = {
          width = 15; # Align keys to 15 characters
        };
        bar = {
          width = 20;
          charElapsed = "#";
          charRemaining = "-";
        };
      };
      modules = [
        "title"
        "separator"
        "os"
        "kernel"
        "uptime"
        {
          type = "packages";
          key = "Nix Pkgs"; # Custom key for packages
          format = "{1} (Nix)";
        }
        "shell"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "battery"
        "colors"
      ];
    };
  };
}