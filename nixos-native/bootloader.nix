{ pkgs, pkgsBundle, myOptions, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 15;

  boot.initrd.kernelModules = if (myOptions.enable-nvidia-gpu == true) then [ "nvidia" ] else [];

  boot.kernelModules = [] ++
  (if (myOptions.enable-nvidia-gpu == true) then ["nvidia-uvm"] else []);

  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ] ++
  # Nvidia GPU Param
  (if (myOptions.enable-nvidia-gpu == true) then [ "nvidia-drm.fbdev=1" "nvidia-drm.modeset=1" ] else []) ++
  # AMD GPU Param
  (if (myOptions.enable-amd-gpu == true) then [ "amdgpu.abmlevel=0" ] else []);
  
  # boot.blacklistedKernelModules = [ "nouveau" ];

  # Kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  # boot.kernelPackages = pkgsBundle.pkgs-stable.linuxKernel.packages.linux_6_12;
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
