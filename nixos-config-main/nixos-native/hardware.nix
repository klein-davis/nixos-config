{ config, pkgs, myOptions, ... }:
{  
  #Most wayland compositors need this
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.vaapiVdpau pkgs.libvdpau-va-gl pkgs.vpl-gpu-rt ];
    };
    nvidia = if (myOptions.enable-nvidia) then {
      open = true; # For stylix
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
