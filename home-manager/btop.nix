{ pkgs, myOptions, ... }:

let
  btopWithGpu = pkgs.btop.override {
    rocmSupport = myOptions.enable-amd-gpu;
    cudaSupport = myOptions.enable-nvidia-gpu;
  };
in
{
  programs.btop = {
    enable = true;
    package = btopWithGpu;
    
    settings = {
      #color_theme = "dracula";
      theme_background = false;
      update_ms = 200;
      # On Auto Off
      shown_boxes = "cpu mem net proc gpu0";
    };
  };

  home.packages = (with pkgs; [ 
    nvtopPackages.intel
  ]);
}