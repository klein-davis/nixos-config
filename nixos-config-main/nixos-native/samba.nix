{ config, pkgs, lib, ... }:

{
  services.samba = {
    enable = true;
    package = pkgs.samba4Full;

    openFirewall = true; # Remains a top-level option for Samba itself

    # --- FIX: 'settings' now directly contains ALL smb.conf sections ---
    # This means 'global' is a section, and 'Public-Folder' is another section,
    # all as direct attributes of 'settings'.
    settings = {
      # This defines the [global] section
      global = { # No quotes around 'global' here, as it's a valid Nix attribute name
        security = "user"; # Corresponds to the global 'security' option in smb.conf
        workgroup = "WORKGROUP";
        "server string" = "NixOS Public Share Server"; # Needs quotes if contains spaces
        "netbios name" = "smbnix"; # Needs quotes if contains spaces

        "guest account" = "nobody";
        "map to guest" = "Bad User";
        "browseable" = "yes"; # Global browseable setting (allows Browse the server for shares)

        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
      };

      # This defines the [Public-Folder] share section directly under 'settings'
      # The key "Public-Folder" becomes the share name in smb.conf
      "Public-Folder" = { # Double quotes needed for share names if they contain special chars or spaces
        comment = "Public folder for anyone to access";
        path = "/home/nixuser/Public"; # Hardcoding the user for simplicity

        browseable = "yes"; # Allows Browse this specific share
        "read only" = "no";
        "guest ok" = "yes"; # Crucial for anonymous access

        "force user" = "nobody";
        "force group" = "nogroup";
        "writable" = "yes";

        "create mask" = "0666";
        "directory mask" = "0777";
      };

      # Example for a [homes] share (if you wanted one):
      # homes = {
      #   comment = "Home Directories";
      #   browseable = "no";
      #   "read only" = "no";
      #   # ... other home share options
      # };
    };
    # --- END FIX for 'settings' structure ---
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true; # Ensures WSD ports are open
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable mDNS for IPv4 name resolution
    publish = {
      enable = true;
      # Samba services are typically published automatically if samba4Full is used
      # but you can explicitly enable them if needed:
      # userServices = true;
      # workstation = true;
      # addresses = true;
    };
    openFirewall = true; # Open firewall for Avahi itself
  };

  # Ensure the /home/nixuser/Public directory exists and has permissions
  systemd.tmpfiles.rules = [
    # This ensures /home/nixuser/Public exists with full permissions for everybody,
    # and is owned by 'nobody' for consistency with guest writes.
    "d /home/nixuser/Public 0777 nobody nogroup"
  ];
}