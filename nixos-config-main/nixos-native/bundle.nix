{ host, ... }: {
  imports = [
    ./bluetooth.nix
    ./bootloader.nix
    ./env.nix
    ./gtk.nix
    ./hardware.nix
    ./hyprland.nix
    ./network.nix
    ./openrgb.nix
    ./packages.nix
    ./power.nix
    # ./samba.nix
    ./security.nix
    ./services.nix
    ./sound.nix
    ./ssh.nix
    ./steam.nix
    ./stylix.nix
    ./system.nix
    ./trim.nix
    ./user.nix
    #./user2.nix
    ./virtmanager.nix
    ./xserver.nix
    ./zram.nix
  ];
  #if (host != "desktop") then
  #        ++ [./distribute-builds];
}
