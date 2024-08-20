{ pkgs, myOptions, ... }: 
{
  networking = {
    hostName = myOptions.hostname;
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      #allowedTCPPorts = [ 22 80 443 59010 59011 ];

      # For steam network file transfer
      allowedTCPPorts = [ 27031 27032 27033 27034 27035 27036 27037 27038 27039 27040 ]; 

      #allowedUDPPorts = [ 59010 59011 ];
      # allowedUDPPortRanges = [
        # { from = 4000; to = 4007; }
        # { from = 8000; to = 8010; }
      # ];
    };
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
