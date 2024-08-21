{ config, pkgs, myOptions, ... }:
{  
  #Most wayland compositors need this
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.vaapiVdpau pkgs.libvdpau-va-gl ];
    };
    nvidia = if (myOptions.enable-nvidia) then {
     modesetting.enable = true;
     powerManagement.enable = true; # Fix sleep?
     nvidiaSettings = true;
     package = config.boot.kernelPackages.nvidiaPackages.stable;
    } else {};
  };
}
