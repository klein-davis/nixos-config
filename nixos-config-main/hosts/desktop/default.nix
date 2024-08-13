{ pkgs, ... }: 
{
  imports = [
    ./hardware-configuration.nix
    ./../../nixos-native/default.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";

  # allow local remote access to make it easier to toy around with the system
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      PermitRootLogin = "yes";
    };
  };
}