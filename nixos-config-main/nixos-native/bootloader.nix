{ pkgs, pkgs-stable, myOptions, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.initrd.kernelModules = if (myOptions.enable-nvidia == true) then [ "nvidia" ] else [];
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ] ++
  (if (myOptions.enable-nvidia == true) then [ "nvidia-drm.fbdev=1" ] else []);
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs-stable.linuxKernel.packages.linux_6_9;
  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_4_19.override {
  #  argsOverride = rec {
  #    src = pkgs.fetchurl {
  #          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
  #          sha256 = "0ibayrvrnw2lw7si78vdqnr20mm1d3z0g6a0ykndvgn5vdax5x9a";
  #    };
  #    version = "6.10.1";
  #    modDirVersion = "6.10.1";
  #    };
  #});
}
