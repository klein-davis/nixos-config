{ pkgs, myOptions, ... }: {
  virtualisation.docker = {
    enable = true;
  };
  users.users.${myOptions.username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker
  ];

  hardware.nvidia-container-toolkit.enable = (myOptions.enable-nvidia-gpu);
  
  # Fix networking issues on docker systems
  boot.kernel.sysctl = {
    "net.ipv6.conf.enp7s0.accept_ra" = 2;  # accept RA even with forwarding on
  };
}