{ lib, pkgs, myOptions, ... }: 
{
  # systemd.services.wpa_supplicant.environment.OPENSSL_CONF = 
  #   if myOptions.enable-enterprise-wifi then { pkgs.writeText "openssl.cnf"
  #   "openssl_conf = openssl_init
  #   [openssl_init]
  #   ssl_conf = ssl_sect
  #   [ssl_sect]
  #   system_default = system_default_sect
  #   [system_default_sect]
  #   Options = UnsafeLegacyRenegotiation
  #   [system_default_sect]
  #   CipherString = Default:@SECLEVEL=0"
  #   } else {};
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.wpa_supplicant.environment.OPENSSL_CONF = pkgs.writeText "openssl.cnf" ''
  openssl_conf = openssl_init
  [openssl_init]
  ssl_conf = ssl_sect
  [ssl_sect]
  system_default = system_default_sect
  [system_default_sect]
  Options = UnsafeLegacyRenegotiation
  [system_default_sect]
  CipherString = Default:@SECLEVEL=0
'';

  networking = {
    hostName = myOptions.hostname;
    networkmanager.enable = true;

    networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
    ];
    
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    firewall = {
      enable = true;
      allowPing = true;

      trustedInterfaces = ["p2p-wl+"];

      # For steam network file transfer
      allowedTCPPorts = ([ 27031 27032 27033 27034 27035 27036 27037 27038 27039 27040
      # For gnome-network-displays
      ] ++ [7236 7250]);
      allowedTCPPortRanges = [
        { from = 11000; to = 15000; } # ROS2
      ];

      allowedUDPPorts = [ 13407 ]
      # For gnome-network-displays
      ++ [7236 5353];
      allowedUDPPortRanges = [
        # { from = 2000; to = 3000; }
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
        # { from = 13000; to = 14000; }
        { from = 11000; to = 15000; } # ROS2
      ];
    };
  };


  services.openssh = {
      enable = myOptions.enable-ssh-access;
      ports = [22];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null;
        PermitRootLogin = "yes";
      };
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    openvpn
    gnome-network-displays
    pkgs.sshfs
  ];
}
