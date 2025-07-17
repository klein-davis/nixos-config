{ config, pkgs, lib, ... }:

{
  # Enable Headscale service
  services.headscale = {
    enable = true;
    address = "0.0.0.0"; # Listen on all interfaces
    port = 8080;         # Default Headscale port
    server_url = "https://your-headscale-domain.com"; # IMPORTANT: Replace with your actual domain or IP
    # You can also use an IP address if you don't have a domain, e.g., "http://192.168.1.100:8080"
    # Make sure to use http or https depending on your setup (with or without a reverse proxy/TLS)

    # Optional: Configure DNS for MagicDNS
    dns = {
      baseDomain = "your-tailnet-domain.com"; # E.g., "my-tailnet.com"
      magic_dns = true;
      # Add nameservers if you want Headscale to act as a DNS server for your Tailnet
      # nameservers = [
      #   "8.8.8.8"
      #   "8.8.4.4"
      # ];
    };

    # Headscale settings can be overridden here. These map directly to config.yaml options.
    settings = {
      # For example, to disable logtail (Tailscale's built-in logging collection)
      logtail = {
        enabled = false;
      };
      # Other common settings:
      # ephemeral_node_inactivity_timeout = "24h"; # Timeout for ephemeral nodes
      # You can find all possible options in Headscale's default config.yaml or the NixOS options.
      # Search for "services.headscale.settings" on search.nixos.org/options
    };

    # Define the user and group Headscale runs as (defaults are usually fine)
    user = "headscale";
    group = "headscale";
  };

  # Open the Headscale port in the firewall
  networking.firewall.allowedTCPPorts = [
    config.services.headscale.port
  ];

  # Optional: If you plan to use a reverse proxy (like Nginx) in front of Headscale
  # This is highly recommended for proper HTTPS with Let's Encrypt.
  # Example with Nginx:
  # services.nginx.enable = true;
  # services.nginx.virtualHosts."your-headscale-domain.com" = {
  #   forceSSL = true;
  #   enableACME = true; # For automatic Let's Encrypt certificates
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
  #     proxyWebsockets = true; # Important for Tailscale client communication
  #   };
  # };
  # Make sure to also allow ports 80 and 443 in your firewall if using Nginx with ACME.
  # networking.firewall.allowedTCPPorts = [ 80 443 ];

  # For DERP (relay servers), if you want to run your own or use custom ones:
  # services.headscale.settings.derp.urls = [
  #   "https://controlplane.tailscale.com/derpmap/default" # Tailscale's public DERP
  #   "https://my-custom-derp.com/derp" # Your own DERP server
  # ];
  # If you want Headscale to run its own DERP server (requires opening UDP port 3478):
  # services.headscale.settings.derp.server = {
  #   enabled = true;
  #   region_id = 999; # A custom region ID
  #   stun_listen_addr = "0.0.0.0:3478"; # Listen for STUN
  # };
  # networking.firewall.allowedUDPPorts = [ 3478 ];





  # nix run nixpkgs#cloudflared -- tunnel login
  # nix run nixpkgs#cloudflared -- tunnel create <your-tunnel-name>
  # sudo cp ~/.cloudflared/YOUR_TUNNEL_ID.json /var/lib/cloudflared/YOUR_TUNNEL_ID.json
  # sudo chown cloudflared:cloudflared /var/lib/cloudflared/YOUR_TUNNEL_ID.json
  # sudo chmod 600 /var/lib/cloudflared/YOUR_TUNNEL_ID.json

  services.cloudflared = {
    enable = true;
    # tunnel ID
    tunnels."54b3cae2-4263-4c78-872a-a064450b531a" = {
      
      credentialsFile = "/var/lib/cloudflared/54b3cae2-4263-4c78-872a-a064450b531a.json";

      ingress = {
        "headscale.kleindavis.xyz" = "http://localhost:8080";
        # "another-service.your-domain.com" = "http://localhost:3000"; # Another example
        default = "http_status:404"; # Catch-all for unmatched requests
      };

      # Optional: You can specify a config file instead of ingress rules directly.
      # configFile = "/etc/cloudflared/config.yml";
    };

    user = "cloudflared";
    group = "cloudflared";
  };

  environment.systemPackages = with pkgs; [
    cloudflared
  ];
}