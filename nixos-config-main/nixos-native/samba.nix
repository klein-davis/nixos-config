{ lib, pkgs, myOptions, ... }: {
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP 
      server string = smbnix
      netbios name = smbnix
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      '';
    shares = {
      public = {
        path = "/home/${myOptions.username}/Public"; 
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes"; 
        "create mask" = "0666"; 
        "directory mask" = "0777"; 
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

}