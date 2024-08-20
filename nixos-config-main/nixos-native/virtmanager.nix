{ pkgsBundle, ... }: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager = {
    enable = true;
    package = pkgsBundle.pkgs-stable.virt-manager;
  };
}

