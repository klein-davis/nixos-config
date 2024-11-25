{ config, pkgs, myOptions, ... }:
{  
  #Most wayland compositors need this
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.vaapiVdpau pkgs.libvdpau-va-gl ];
    };
    nvidia = if (myOptions.enable-nvidia) then {
      open = true; # For stylix
      modesetting.enable = true;
      powerManagement.enable = true; # Fix sleep?
      nvidiaSettings = true;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    } else {};
  };
}
