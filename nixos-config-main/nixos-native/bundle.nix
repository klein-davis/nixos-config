{ host, ... }: {
  imports = [
    ./bluetooth.nix
    ./bootloader.nix
    ./env.nix
    ./hardware.nix
    ./hyprland.nix
    ./network.nix
    ./openrgb.nix
    ./packages.nix
    # ./samba.nix
    ./security.nix
    ./services.nix
    ./sound.nix
    ./steam.nix
    # ./stylix.nix
    ./system.nix
    ./trim.nix
    ./user.nix
    ./virtmanager.nix
    ./xserver.nix
    ./zram.nix
  ];
  #if (host != "desktop") then
  #        ++ [./distribute-builds];
}
