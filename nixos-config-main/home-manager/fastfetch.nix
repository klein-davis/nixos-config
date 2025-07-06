{ config, pkgs, lib, ... }:

{
  # Ensure fastfetch program is enabled
  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetch; # Make sure fastfetch is available in your pkgs
    
    # Define the settings that will be written to ~/.config/fastfetch/config.jsonc
    settings = {
      # The "$schema" line is for JSONC schema validation in editors,
      # and is not part of the Nix attribute set itself.
      # It should be omitted here.

      logo = {
        type = "builtin";
        height = 20;
        width = 30;
        padding = {
          top = 4;
          left = 3;
        };
      };

      "modules" = [
        "break"
        "break"
        "break"
         {
            "type" = "os";
            "key" = "OS   ";
            "keyColor" = "31";
        }
        {
            "type" = "kernel";
            "key" = " ├  ";
            "keyColor" = "31";
        }
        {
            "type" = "packages";
            "format" = "{} (pacman)";
            "key" = " ├ 󰏖 ";
            "keyColor" = "31";  
        }
        {
            "type" = "shell";
            "key" = " └  ";
            "keyColor" = "31"; 
        }
        "break"
        {
            "type" = "wm";
            "key" = "WM   ";
            "keyColor" = "32"; 
        }
        {
            "type" = "wmtheme";
            "key" = " ├ 󰉼 ";
            "keyColor" = "32";
        }
        {
            "type" = "icons";
            "key" = " ├ 󰀻 ";
            "keyColor" = "32";
        }
        {
            "type" = "cursor";
            "key" = " ├  ";
            "keyColor" = "32"; 
        }
        {
            "type" = "terminal";
            "key" = " ├  ";
            "keyColor" = "32";
        }
        {
            "type" = "terminalfont";
            "key" = " └  ";
            "keyColor" = "32"; 
        }
        "break"
        {
            "type" = "host";
            "format" = "{5} {1} Type {2}";
            "key" = "PC   ";
            "keyColor" = "33";
        }
        {
            "type" = "cpu";
            "format" = "{1} ({3}) @ {7} GHz";
            "key" = " ├  ";
            "keyColor" = "33";
        }
        {
            "type" = "gpu";
            "format" = "{1} {2} @ {12} GHz";            
            "key" = " ├ 󰢮 ";
            "keyColor" = "33";
        }
        {
            "type" = "memory";
            "key" = " ├  ";
            "keyColor" = "33";
        }
        {
            "type" = "swap";
            "key" = " ├ 󰓡 ";
            "keyColor" = "33";
        }
        {
            "type" = "disk";
            "key" = " ├ 󰋊 ";
            "keyColor" = "33";
        }
        {
            "type" = "monitor";
            "key" = " └  ";
            "keyColor" = "33";
        }
        "break"
        "break"
        
        "battery"
        "colors"
      ];
    };
  };

}