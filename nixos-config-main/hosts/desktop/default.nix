{ pkgs, ... }: 
{
  imports = [
    ./hardware-configuration.nix
    ./../../nixos-native/default.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";
}