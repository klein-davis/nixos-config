{ pkgs, myOptions, ... }: {
  services.jellyfin = {
    enable = true;
    openFirewall = true; # port 8096 (HTTP) and 8920 (HTTPS)
    user = "${myOptions.username}";
  };

  services.ersatztv = {
    enable = true;
    user = "${myOptions.username}";
  };

  # Upstream ersatztv module doesn't add bash to the service's PATH, but
  # ErsatzTV shells out to bash to run its ffmpeg transcode pipeline for the
  # .ts IPTV endpoint (what Jellyfin's M3U tuner hits). Without this, every
  # request from Jellyfin gets an instant 500 (Win32Exception: no such file
  # or directory trying to start process 'bash').
  systemd.services.ersatztv.path = [ pkgs.bash ];

  # users.users.jellyfin.extraGroups = [ "users" ];

  environment.systemPackages = [
    pkgs.jellyfin-desktop
    pkgs.jellyfin-mpv-shim
    # pkgs.jellyfin
    # pkgs.jellyfin-web
    # pkgs.jellyfin-ffmpeg
  ];
}