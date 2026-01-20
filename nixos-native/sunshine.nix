{ pkgs, ... } : {
  services.sunshine = {
    enable = true;
    autoStart = true;
  };
  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
}