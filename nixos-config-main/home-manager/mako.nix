{ config, pkgs, lib, ... }:
{
  services = {
    mako = {
      enable = true;
      settings = {
        anchor = "bottom-right";
        # font = "JetBrainsMono Nerd Font 12";
        padding = "15";
        default-timeout = 5000;
        # borderSize = 2;
        # borderRadius = 5;
        background-color = lib.mkForce "#2c2c2c";
        # borderColor = "#b5b5b5";
        # progressColor = "over #313244";
        # textColor = "#ffffff";
        icons = true;
        actions = true;

        # These settings were previously in extraConfig
        text-alignment = "center"; # Maps from 'text-alignment'
        "urgency=high" = { # This is now a direct attribute set key
          defaultTimeout = 100000000; # Maps from 'default-timeout'
          # border-color = "#fab387"; # Maps from 'border-color'
          # background-color = lib.mkForce "#2c2c2c";
        };
        "urgency=low" = { # This is now a direct attribute set key
          # border-color = "#fab387"; # Maps from 'border-color'
          # background-color = lib.mkForce "#2c2c2c";
        };
      };
    };
  };
}
