{ pkgsBundle, ... }:{
  programs.steam = {
    enable = true;
    package = pkgsBundle.pkgs-main.steam;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  }; 
}
