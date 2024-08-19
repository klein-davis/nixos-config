{ pkgs, config, ... }: 
{
  imports = [
    ./hardware-configuration.nix
    ./../../nixos-native/default.nix
  ];
}
