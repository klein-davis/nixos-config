{
  # Samba Config
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = optigroup
      server string = Nixos Optiplex NAS
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      #hosts allow = 192.168.0. 127.0.0.1 localhost
      #hosts deny = 0.0.0.0/0
      #guest account = nobody
      map to guest = Bad User # allows connections without user and passwd
      name resolve order = bcast host
    '';
    shares = {
      public = {
        path = "/share/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "smbuser";
        "force group" = "smbgroup";
      };
      private = {
        path = "/share/private";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
