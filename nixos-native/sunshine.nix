{ pkgs, ... } : {
  services.sunshine = {
    enable = true;
    autoStart = true;
  };
  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
  networking.firewall = {
    allowedTCPPorts = [ 48010 ];
    allowedUDPPorts = [ 48010 ];
  };
}