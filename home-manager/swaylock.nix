{ pkgs, lib, config, inputs, pkgsBundle, ... }: 
{
  programs.swaylock = {
    enable = true;
    package = pkgsBundle.pkgs-stable.swaylock-effects;
    settings = {
      clock = true;
      datestr = "";
      screenshots = true;
      
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      
      effect-blur = "5x5";
      effect-vignette = "0.5:0.5";
      effect-pixelate = 1;
      /* 050505,515151,b5b5b5,7c7c7c,3c3c3c,272727,848484,737474,343434,1c1c1c */
      #color="1e1e2e";
      #bs-hl-color="f5e0dc"; # ???
      # key-hl-color="b5b5b5"; # key press color
      #caps-lock-bs-hl-color="f5e0dc"; # ???
      # caps-lock-key-hl-color="a6e3a1"; # key press color
      # ring-color="515151"; # base ring color
      # ring-clear-color="b5b5b5"; 
      # ring-caps-lock-color="fab387";
      # ring-ver-color="b5b5b5";
      # ring-wrong-color="f03555";
      # text-color="ffffff";
      # text-clear-color="ffffff";
      # text-caps-lock-color="ffffff";
      # text-ver-color="ffffff";
      # text-wrong-color="ffffff";
      # layout-text-color="ffffff";

      # inside-color="00000000";
      # inside-clear-color="00000000";
      # inside-caps-lock-color="00000000";
      # inside-ver-color="00000000";
      # inside-wrong-color="00000000";
      # layout-bg-color="00000000";
      # layout-border-color="00000000";

      # line-color="00000000";
      # line-clear-color="00000000";
      # line-caps-lock-color="00000000";
      # line-ver-color="00000000";
      # line-wrong-color="00000000";
      # separator-color="00000000";
    };
  };
}
