{ pkgs, myOptions, ... }: {
  services.jellyfin = {
    enable = true;
    openFirewall = true; # port 8096 (HTTP) and 8920 (HTTPS)
    user = "${myOptions.username}";
  };

  # users.users.jellyfin.extraGroups = [ "users" ];

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "nixuser";
    group = "users";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "nixuser";
    group = "users";
  };
}