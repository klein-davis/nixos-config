{ pkgs, ... }: 
{
  programs.btop = {
    enable = true;
    
    settings = {
      #color_theme = "dracula";
      theme_background = false;
      update_ms = 100;
    };
  };

  home.packages = (with pkgs; [ nvtopPackages.intel ]);
}