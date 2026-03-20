{ pkgs, lib, pkgsBundle, myOptions, ... }:
{
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # # boot.loader.systemd-boot.configurationLimit = 10;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # # Use 'nodev' for UEFI installations (which you are using, given the 'efi' option above)
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.splashImage = lib.mkForce "/etc/nixos/grub/my-grub-background.jpg";
  boot.loader = {
    efi = {
      # This is often the culprit. We're removing reliance on it.
      canTouchEfiVariables = false; 
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      # ADD THIS LINE to force installation to the fallback path (\EFI\BOOT\BOOTX64.EFI)
      efiInstallAsRemovable = true; 
    };
  };

  boot.initrd.kernelModules = []
  ++ (if (myOptions.enable-nvidia-gpu == true) then [ "nvidia" ] else [])
  ++ (if (myOptions.enable-amd-gpu == true) then [ "amdgpu" ] else []);

  boot.kernelModules = [] ++
  (if (myOptions.enable-nvidia-gpu == true) then ["nvidia-uvm"] else []);

  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ] ++
  # Nvidia GPU Param
  (if (myOptions.enable-nvidia-gpu == true) then [ "nvidia-drm.fbdev=1" "nvidia-drm.modeset=1" ] else []) ++
  # AMD GPU Param
  (if (myOptions.enable-amd-gpu == true) then [ "amdgpu.abmlevel=0" ] else []) ++
  
  ( ["usbcore.autosuspend=-1"] );
  
  # boot.blacklistedKernelModules = [ "nouveau" ];

  # Kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_18;
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
  
  # To prevent getting stuck at shutdown
  systemd.settings = {
    Manager = {
      DefaultTimeoutStopSec = "5s";
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 128;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.supportedFilesystems = [ "ntfs" ];
  environment.systemPackages = with pkgs; [
    efibootmgr ntfs3g
  ];

  # Enable zram compressed swap space support
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
    priority = 999;
  };

}
