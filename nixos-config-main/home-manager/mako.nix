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
        border-size = 2;
        border-radius = 5;
        # background-color = "#2c2c2c";
        # border-color = "#b5b5b5";
        # progress-color = "over #313244";
        # text-color = "#ffffff";
        icons = true;
        actions = true;

        text-alignment = "center";
        "urgency=high" = {
          default-timeout = 1000;
          # border-color = "#fab387";
          # background-color = "#2c2c2c";
        };
        "urgency=low" = {
          # border-color = "#fab387";
          # background-color = "#2c2c2c";
        };
      };
    };
  };
}
