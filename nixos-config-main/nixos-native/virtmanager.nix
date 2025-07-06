{ pkgs, pkgsBundle, ... }: {
  # Enable virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
    };
    qemu.vhostUserPackages = with pkgs; [
      virtiofsd
    ];
  };

  # virtualisation.waydroid.enable = true;

  programs.virt-manager = {
    enable = true;
    package = pkgsBundle.pkgs-stable.virt-manager;
  };
}

