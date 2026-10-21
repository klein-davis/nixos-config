{ inputs, host, ... }: {
  imports = []
    ++ [(import ./bluetooth.nix)]                   # Bluetooth configuration
    ++ [(import ./bootloader.nix)]                  # Bootloader settings
    ++ [(import ./display.nix)]                     # Display configuration
    ++ [(import ./env.nix)]                         # Environment variables
    ++ [(import ./graphics.nix)]                    # Hardware-specific configurations
    ++ [(import ./network.nix)]                     # Network configurations
    ++ [(import ./nix-index.nix)]                   # nix-index (command-not-found database)
    ++ [(import ./packages/default.nix)]            # System-wide packages
    ++ [(import ./power.nix)]                       # Power management settings
    ++ [(import ./security.nix)]                    # Security configurations
    ++ [(import ./services.nix)]                    # System services
    ++ [(import ./sound.nix)]                       # Sound settings
    ++ [(import ./style.nix)]                       # System theming/styling
    ++ [(import ./sunshine.nix)]                    # Game streaming server
    ++ [(import ./system.nix)]                      # Core system configurations
    ++ [(import ./user.nix)]                        # User-specific settings
    ++ [(import ./virtmanager.nix)]                 # Virt-Manager for VMs
    ++ [(import ./vpn.nix)]                         # Tailscale VPN Config

    ++ (if host == "desktop" then [(import ./jellyfin.nix)] else [])     # Media server
    ++ (if host == "desktop" then [(import ./cloudflared.nix)] else [])  # Cloudflare tunnel
    ++ (if host == "desktop" then [(import ./rustdesk.nix)] else []);    # RustDesk server
}