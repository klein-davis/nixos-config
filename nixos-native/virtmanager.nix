{ pkgs, pkgsBundle, ... }: {
  # Enable virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;          # TPM emulator
      vhostUserPackages = with pkgs; [
        virtiofsd
      ];
    };
  };

  # virtualisation.waydroid.enable = true;

  programs.virt-manager = {
    enable = true;
    package = pkgsBundle.pkgs-stable.virt-manager;
  };

  virtualisation.waydroid.enable = true;
  # Kernel lacks legacy iptables tables, so waydroid-net.sh must use nft
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  networking.firewall.trustedInterfaces = [ "waydroid0" "virbr0" ];
  boot.kernelModules = [ "binder_linux" "ashmem_linux" ];
  # networking.nftables.enable = true;

  environment.systemPackages = [
    pkgs.virt-viewer
    pkgs.swtpm # software tpm
  ];
}

