{ config, pkgs, lib, ... }:

{

  # sudo tailscale up --login-server https://head.kleindavis.xyz
  # sudo tailscale set --advertise-exit-node
  services.tailscale = {
    enable = true;
    openFirewall = true;
     extraUpFlags = [ "--login-server=http://192.168.12.180:8080" ];
    # client server both
    useRoutingFeatures = "client";
  };
  networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
  # Needed if useRoutingFeatures == server or both
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1; # Enable IPv4 forwarding
    "net.ipv6.conf.all.forwarding" = 1; # Enable IPv6 forwarding
  };
  networking.firewall.checkReversePath = "loose";

  # Enable Headscale service
  services.headscale = {
    enable = true;
    address = "0.0.0.0"; # Back here, directly under services.headscale
    port = 8080;         # Back here, directly under services.headscale
    user = "headscale"; # Use your configured user

    settings = {
      server_url = "https://head.kleindavis.xyz"; # Using the variable here
      web_ui = {
        enabled = true;
        # path = "/web"; # sometimes it's on a subpath
      };

      # DNS configuration now named dns_config, and inside settings
      dns = {
        base_domain = "tail.kleindavis.xyz"; # Note the underscore and use the variable
        magic_dns = true;
        search_domains = ["head.kleindavis.xyz"]; # Recommended by the example
        nameservers.global = [
          "1.1.1.1"
          "9.9.9.9" # Good default public DNS servers
        ];
      };

      ip_prefixes = [ # Essential for Tailscale IPs
        "100.64.0.0/10"
      ];

      # Logtail simplified syntax
      logtail.enabled = false;

      # You can find all possible options in Headscale's default config.yaml or the NixOS options.
      # Search for "services.headscale.settings" on search.nixos.org/options
    };

    # Define the user and group Headscale runs as (defaults are usually fine)
    # user = "headscale"; # Already defined above
    group = "headscale";
  };

  # Open the Headscale port in the firewall
  networking.firewall.allowedTCPPorts = [
    config.services.headscale.port
  ];


  # nix run nixpkgs#cloudflared -- tunnel login
  # nix run nixpkgs#cloudflared -- tunnel create <your-tunnel-name>
  # sudo cp ~/.cloudflared/YOUR_TUNNEL_ID.json /var/lib/cloudflared/YOUR_TUNNEL_ID.json
  # sudo chown cloudflared:cloudflared /var/lib/cloudflared/YOUR_TUNNEL_ID.json
  # sudo chmod 600 /var/lib/cloudflared/YOUR_TUNNEL_ID.json
  # https://gemini.google.com/app/064ffd0a1e24b1e6

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 25000000; # Roughly 2.5 MB, as recommended often for QUIC
    "net.core.wmem_max" = 25000000;
  };

  services.cloudflared = {
    enable = true;
    # tunnel ID
    tunnels."6207a673-e90b-431b-a686-14d347fae860" = {
      
      credentialsFile = "/var/lib/cloudflared/6207a673-e90b-431b-a686-14d347fae860.json";

      ingress = {
        "head.kleindavis.xyz" = "http://localhost:8080";
        "silly.kleindavis.xyz" = "https://google.com";
        # The default rule is just another key in the attribute set
        
      };

      default = "http_status:404";

      # Optional: You can specify a config file instead of ingress rules directly.
      # configFile = "/etc/cloudflared/config.yml";
    };

  };

  environment.systemPackages = with pkgs; [
    cloudflared
  ];
}