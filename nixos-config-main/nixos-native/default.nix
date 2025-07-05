{ inputs, host, ... }: {
  imports = []
    ++ [(import ./bluetooth.nix)]                   # Bluetooth configuration
    ++ [(import ./bootloader.nix)]                  # Bootloader settings
    ++ [(import ./env.nix)]                         # Environment variables
    ++ [(import ./hardware.nix)]                    # Hardware-specific configurations
    ++ [(import ./hyprland.nix)]                    # Hyprland Wayland compositor
    ++ [(import ./network.nix)]                     # Network configurations
    ++ [(import ./openrgb.nix)]                     # OpenRGB for lighting control
    ++ [(import ./packages.nix)]                    # System-wide packages
    ++ [(import ./power.nix)]                       # Power management settings
    # ++ [(import ./samba.nix)]                       # Samba file sharing (currently disabled)
    ++ [(import ./security.nix)]                    # Security configurations
    ++ [(import ./services.nix)]                    # System services
    ++ [(import ./sound.nix)]                       # Sound settings
    ++ [(import ./ssh.nix)]                         # SSH configuration
    ++ [(import ./steam.nix)]                       # Steam integration
    ++ [(import ./stylix.nix)]                      # System theming/styling
    ++ [(import ./system.nix)]                      # Core system configurations
    ++ [(import ./trim.nix)]                        # SSD TRIM operations
    ++ [(import ./user.nix)]                        # User-specific settings
    ++ [(import ./virtmanager.nix)]                 # Virt-Manager for VMs
    ++ [(import ./xserver.nix)]                     # X server configuration
    ++ [(import ./zram.nix)];                       # Zram for compressed swap
  # if (host != "desktop") then
  #         ++ [./distribute-builds]; # Conditional import for non-desktop hosts
}