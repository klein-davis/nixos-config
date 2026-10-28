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

  programs.virt-manager = {
    enable = true;
    package = pkgsBundle.pkgs-stable.virt-manager;
  };

  networking.firewall.trustedInterfaces = [ "virbr0" ];
  # networking.nftables.enable = true;

  environment.systemPackages = [
    pkgs.virt-viewer
    pkgs.swtpm # software tpm
  ];
}

