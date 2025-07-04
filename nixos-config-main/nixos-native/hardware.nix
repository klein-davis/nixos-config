{ config, pkgs, myOptions, ... }:
{  
  #Most wayland compositors need this
  hardware = {
    graphics = {
      enable = true;
      # Some options for amdgpu
      enable32Bit = true;
      extraPackages = with pkgs; [ 
        vaapiVdpau
        libvdpau-va-gl 
        vpl-gpu-rt
      ] 
      ++ (if myOptions.enable-amd-gpu then (with pkgs; 
      [amdvlk mesa vulkan-tools]) else []);
      # ++ (if myOptions.enable-amd-gpu then [ pkgs.mesa pkgs.mesa.drivers.radeonsi pkgs.mesa.drivers.amdvlk pkgs.libva-utils] else []);

      # extraPackages32 = []
      # ++ (if myOptions.enable-amd-gpu then [pkgs.pkgsi686Linux.mesa.drivers.radeonsi pkgs.pkgsi686Linux.mesa.drivers.radeonsi] else []);
    };
    nvidia = if (myOptions.enable-nvidia-gpu) then {
      open = true; # For stylix
      # open = false;
      modesetting.enable = true;
      powerManagement.enable = true; # Fix sleep?
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;

      # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #   version = "555.58";
      #   sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
      #   sha256_aarch64 = "sha256-7XswQwW1iFP4ji5mbRQ6PVEhD4SGWpjUJe1o8zoXYRE=";
      #   openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
      #   settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
      #   persistencedSha256 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
      # };
    } else {};
  };
}
