{ lib, pkgs, ... }:
{
# Enable Headscale service
  services.headscale = {
    enable = false;
    address = "0.0.0.0"; # Back here, directly under services.headscale
    port = 8080;         # Back here, directly under services.headscale
    user = "headscale"; # Use your configured user
    group = "headscale";

    settings = {
      server_url = "https://head.kleindavis.xyz"; # Using the variable here

      web_ui = {
        enabled = true;
        path = "/web"; # sometimes it's on a subpath
      };

      # DNS configuration now named dns_config, and inside settings
      dns = {
        base_domain = "tail.kleindavis.xyz"; # Note the underscore and use the variable
        magic_dns = true;
        search_domains = ["head.kleindavis.xyz"]; # Recommended by the example
        nameservers.global = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };

      ip_prefixes = [ # Essential for Tailscale IPs
        "100.64.0.0/10"
        "fd7a:115c:a1e0::/48"
      ];

      # Logtail simplified syntax
      logtail.enabled = false;

      # You can find all possible options in Headscale's default config.yaml or the NixOS options.
      # Search for "services.headscale.settings" on search.nixos.org/options
    };

    # Define the user and group Headscale runs as (defaults are usually fine)
    # user = "headscale"; # Already defined above
    
  };
  # https://github.com/cloudflare/cloudflared/issues/990
  # nix run nixpkgs#cloudflared -- tunnel login
  # nix run nixpkgs#cloudflared -- tunnel create <your-tunnel-name>
  # cloudflared tunnel route dns TUNNEL_UUID prefix.my-website.com
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
        "head.kleindavis.xyz" = "http://10.31.0.9:8080";
        "minecraft.kleindavis.xyz" = "tcp://localhost:41973";
        "silly.kleindavis.xyz" = "https://google.com";        
        "www.roboticcardinals.org" = "http://localhost:5000";
        "api.roboticcardinals.org" = "http://localhost:5001";
        "jellyfin.kleindavis.xyz" = "http://localhost:8096";   
      };

      default = "http_status:404";

      # Optional: You can specify a config file instead of ingress rules directly.
      # configFile = "/etc/cloudflared/config.yml";
    };

  };

  environment.systemPackages = with pkgs; [
    cloudflared
    tailscale
  ];

  services.immich.enable = true;
  services.immich.package = pkgs.immich;
  services.immich.port = 2283;
  services.immich.host = "0.0.0.0";
  services.immich.openFirewall = true;
}