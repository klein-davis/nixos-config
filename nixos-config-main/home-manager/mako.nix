{ config, pkgs, lib, ... }:
{
  services = {
    mako = {
      package = pkgs.mako;
      enable = true;
      settings = {
        actions = lib.mkForce "1";
        anchor = "bottom-right";
        # font = "JetBrainsMono Nerd Font 12";
        padding = "15";
        default-timeout = 5000;
        border-size = 2;
        border-radius = 5;
        background-color = lib.mkForce "#${config.lib.stylix.colors.base00}";
        # border-color = "#b5b5b5";
        # progress-color = "over #313244";
        # text-color = "#ffffff";
        icons = "1";

        text-alignment = "center";
        "urgency=high" = {
          default-timeout = 1000;
          # border-color = "#fab387";
          # background-color = "#2c2c2c";
          background-color = lib.mkForce "#${config.lib.stylix.colors.base00}";
        };
        "urgency=low" = {
          # border-color = "#fab387";
          # background-color = "#2c2c2c";
          background-color = lib.mkForce "#${config.lib.stylix.colors.base00}";
        };
      };
    };
  };
}
