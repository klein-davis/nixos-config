{ lib, pkgs, pkgsBundle, ... }:
{
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
        # "head.kleindavis.xyz" = "http://10.31.0.9:8080";
        # "minecraft.kleindavis.xyz" = "tcp://localhost:41973";    
        "www.roboticcardinals.org" = "http://localhost:5000";
        "api.roboticcardinals.org" = "http://localhost:5001";
        "jellyfin.kleindavis.xyz" = "http://localhost:8096";
        "homeassistant.kleindavis.xyz" = "http://homeassistant.tailf1460c.ts.net:8123";
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

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     postgresql_16 = prev.postgresql_16.overrideAttrs (old: {
  #       passthru = old.passthru // {
  #         pkgs = prev.postgresql_16.pkgs // {
  #           vectorchord = prev.postgresql_16.pkgs.vectorchord.overrideAttrs (_: rec {
  #             version = "0.5.3";
  #             src = prev.fetchFromGitHub {
  #               owner = "tensorchord";
  #               repo = "VectorChord";
  #               rev = version;
  #               hash = "sha256-+c1Uf/3rp+HuthDVPLloJF2MQPW3Xho897Z2eAnG6aM=";
  #             };
  #           });
  #         };
  #       };
  #     });
  #   })
  # ];

  services.immich.enable = true;
  # services.immich.package = pkgsBundle.pkgs-main.immich;
  services.immich.port = 2283;
  services.immich.host = "0.0.0.0";
  services.immich.openFirewall = true;
}