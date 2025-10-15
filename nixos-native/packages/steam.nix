{ pkgs, pkgsBundle, ... }:{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgsBundle.pkgs-main.steam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraPackages = with pkgs; [
      steam-run
    ];
  }; 
  environment.systemPackages = with pkgs; [
    mangohud
    steamcmd
    steam-tui
  ];
  programs.gamemode.enable = true;
}