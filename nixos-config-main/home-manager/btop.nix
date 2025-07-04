{ config, pkgs, myOptions, ... }:

let
  # Override btop to enable GPU support
  btopWithGpu = pkgs.btop.override {
    rocmSupport = myOptions.enable-amd-gpu;
    cudaSupport = myOptions.enable-nvidia-gpu;
  };
in
{
  programs.btop = {
    enable = true;
    # Use our custom btop package with GPU support
    package = btopWithGpu;
    
    settings = {
      # Your existing settings are kept here
      #color_theme = "dracula";
      theme_background = false;
      update_ms = 200;
      # On Auto Off
      shown_boxes = "cpu mem net proc gpu0";
    };
  };

  home.packages = (with pkgs; [ 
    nvtopPackages.intel
    # If you have an AMD GPU, you might need to ensure ROCm is available for btop,
    # though with static linking, it might be less critical here than in a system-wide NixOS config.
    # pkgs.rocmPackages.rocm-smi # This is generally for the system, but might be useful for other tools.
  ]);

  # If you're managing NVIDIA drivers through Home Manager (less common, usually in NixOS config)
  # Refer to your NixOS configuration for GPU driver setup.
}