{ pkgs, ... }: {
  # Self-hosted RustDesk server (hbbs ID/rendezvous + hbbr relay).
  # Public key for clients: /var/lib/rustdesk/id_ed25519.pub
  services.rustdesk-server = {
    enable = true;
    signal.relayHosts = [ "100.111.87.46" ]; # desktop's Tailscale IP
    # Ports are opened on tailscale0 only, below.
    openFirewall = false;
  };

  environment.systemPackages = [
    pkgs.rustdesk
  ];

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
    allowedUDPPorts = [ 21116 ];
  };
}
