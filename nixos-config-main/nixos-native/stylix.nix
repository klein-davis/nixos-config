{ config, pkgs, inputs, myOptions, ... }:

{
  imports = [ inputs.stylix.nixosModules.stylix ];
  stylix = {
    enable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/edge-light.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/deep-oceanic-next.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/twilight.yaml";
    base16Scheme = {
    #   # base00 = "101010";
    #   # base01 = "686868";
    #   # base02 = "525252";
    #   # base03 = "686868";
    #   # base04 = "868686";
    #   # base05 = "8E8E8E";
    #   # base06 = "747474";
    #   # base07 = "7C7C7C";
    #   # base08 = "F7F7F7";
    #   # base09 = "A0A0A0";
    #   # base0A = "868686";
    #   # base0B = "8E8E8E";
    #   # base0C = "747474";
    #   # base0D = "7C7C7C";
    #   # base0E = "B9B9B9";
    #   # base0F = "A0A0A0";
      
      base00 = "1A1E24";
      base01 = "4C566A";
      base02 = "3B4252";
      base03 = "606A7C";
      base04 = "8FA3B8";
      base05 = "B0C4DE";
      base06 = "9EB3C9";
      base07 = "CFE2F3";
      base08 = "E0F2FF";
      base09 = "8BA6C1";
      base0A = "67B8E6";
      base0B = "85C1E9";
      base0C = "2196F3";
      base0D = "1565C0";
      base0E = "AED6F1";
      base0F = "5D85B2";

    };

    # polarity = "light";

    targets = {
      gtk.enable = true;
      qt.platform = "qtct";
    };
    fonts.sizes = {
      applications = 12;
      terminal = 10;
      desktop = 10;
      popups = 10;
    };
 
    opacity = {
      applications = 0.0;
      terminal = 0.1;
      desktop = 0.0;
      popups = 0.0;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 15;
    };

    # cursor = {
    #   name = "Nordzy-cursors";
    #   package = pkgs.nordzy-cursor-theme;
    #   # size = 15;
    # };
    
  };
}