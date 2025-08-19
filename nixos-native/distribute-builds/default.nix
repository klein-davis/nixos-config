{ config, pkgs, lib, ... }: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "${config.options.buildHost}";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
  ];
  programs.ssh.extraConfig = ''
Host builder
  HostName ${config.options.buildHost}
  Port 2222
  User builder
  IdentitiesOnly yes
  IdentityFile /root/.ssh/id_builder
  '';
}
