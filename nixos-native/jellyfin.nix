{ lib, pkgs, myOptions, ... }:
let
  # nixpkgs' ersatztv builds the legacy app from source and doesn't ship the
  # ErsatzTV Next engine (ersatztv-channel) that upstream's release tarballs
  # bundle. Without it the .ts/segmenter streams return zero bytes. Version
  # matches legacy's .github/next-tag for ersatztv 26.11.3.
  ersatztv-next = pkgs.stdenv.mkDerivation rec {
    pname = "ersatztv-next";
    version = "0.2.2";
    src = pkgs.fetchurl {
      url = "https://github.com/ErsatzTV/next/releases/download/v${version}/ersatztv-next-v${version}-linux-x64.tar.gz";
      hash = "sha256-/xo4ya4lrx1mctj1fNWfU1tir0BhXzGXTKbo7hdHiik=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 ersatztv-channel ersatztv ersatztv-playout-generator $out/bin/
      runHook postInstall
    '';
    meta.platforms = [ "x86_64-linux" ];
  };
in {
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

  # The nixpkgs-built ErsatzTV 26.11.3 crashes on startup under DynamicUser
  # (IOException creating the 'Global\ErsatzTV.Singleton.*' named mutex).
  # Running as the real user without DynamicUser works.
  systemd.services.ersatztv.serviceConfig.DynamicUser = lib.mkForce false;

  # Avoid the startup 503 when ErsatzTV syncs libraries before Jellyfin is up.
  systemd.services.ersatztv.after = [ "jellyfin.service" ];

  # ersatztv-channel dlopens libcuda to probe NVENC; NixOS keeps it here.
  systemd.services.ersatztv.environment.LD_LIBRARY_PATH = "/run/opengl-driver/lib";

  # Tell ErsatzTV where to find ersatztv-channel (see ersatztv-next above).
  systemd.services.ersatztv.environment.ETV_NEXT_FOLDER = "${ersatztv-next}/bin";

  # users.users.jellyfin.extraGroups = [ "users" ];

  environment.systemPackages = [
    pkgs.jellyfin-desktop
    pkgs.jellyfin-mpv-shim
    # pkgs.jellyfin
    # pkgs.jellyfin-web
    # pkgs.jellyfin-ffmpeg
  ];
}