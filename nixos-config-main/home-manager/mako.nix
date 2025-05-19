{ config, pkgs, ... }: 
{
  services = {
    mako = {
      enable = true;
      settings = {
        anchor = "bottom-right";
        font = "JetBrainsMono Nerd Font 12";
        padding = "15";
        defaultTimeout = 5000;
        borderSize = 2;
        borderRadius = 5;
        backgroundColor = "#2c2c2c";
        borderColor = "#b5b5b5";
        progressColor = "over #313244";
        textColor = "#ffffff";
        icons = true;
        actions = true;
        # extraConfig = ''
        #   text-alignment=center
        #   [urgency=high]
        #   default-timeout=100000000
        #   border-color=#fab387
        # '';
      };
    };
  };
}
