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
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";   # <-- tell NM to use resolved
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
    
    search = [ "tailf1460c.ts.net" ];
    firewall = {
      enable = true;
      allowPing = true;

      trustedInterfaces = ["p2p-wl+"];

      # For steam network file transfer
      allowedTCPPorts = ([ 27031 27032 27033 27034 27035 27036 27037 27038 27039 27040 ]
      # For gnome-network-displays
      ++ [7236 7250]
      # For Arduino OTA
      ++ [48266]
      # For LocalSend
      ++ [53317]);
      allowedTCPPortRanges = [
        { from = 11000; to = 15000; } # ROS2
      ];

      allowedUDPPorts = [ 13407 ]
      # For gnome-network-displays
      ++ [7236 5353]
      # For LocalSend
      ++ [53317];
      allowedUDPPortRanges = [
        # { from = 2000; to = 3000; }
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
        # { from = 13000; to = 14000; }
        { from = 11000; to = 15000; } # ROS2
      ];
    };
  };

  # services.dnscrypt-proxy = {
  #   enable = true;
  #   settings = {
  #     listen_addresses = [ "127.0.0.1:5300" ];
  #     server_names = [ "cloudflare" "google" ];
  #     doh_servers = true;
  #     dnscrypt_servers = false;
  #     ipv4_servers = true;
  #     ipv6_servers = false;
  #     require_dnssec = true;
  #     require_nolog = true;
  #   };
  # };

  # Point systemd-resolved to dnscrypt-proxy
  # services.resolved = {
  #   enable = true;
  #   settings = {
  #     Resolve = {
  #       DNS = [ "127.0.0.1:5300" ];
  #       # DNSStubListener = "no";
  #       DNSSEC = "false"; # dnscrypt-proxy handles this
  #       Domains = [ "~ts.net" ]; # route ts.net queries separately
  #     };
  #   };
  # };
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        # DNS = "100.100.100.100 192.168.12.101 1.1.1.1 8.8.8.8";
        DNS = "10.31.0.14";
        FallbackDNS = "8.8.8.8 1.1.1.1";
        Domains = "~ts.net ~tailf1460c.ts.net";
        DNSSEC = "false";
      };
    };
  };

  systemd.services.dnscrypt-proxy2.before = [ "nss-lookup.target" ];

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
