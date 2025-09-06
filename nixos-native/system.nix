{ self, pkgs, lib, inputs, myOptions, ...}: 
{
  imports = [
    # inputs.nix-gaming.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index 
  ];

  boot.tmp.cleanOnBoot = true;

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs-unstable;
  };

  # Nix Shared Libraires
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    boost
    cairo
    cmake
    cups
    curl
    dbus
    e2fsprogs
    expat
    fontconfig
    freetype
    fuse3
    gdk-pixbuf
    glib
    glibc
    gtk3
    icu
    krb5
    libappindicator-gtk3
    libcap
    libdrm
    libGL
    libGLU
    libglvnd
    libkrb5
    libnotify
    libpulseaudio
    libunwind
    libusb1
    libuuid
    libxkbcommon
    libxml2
    mesa
    ncurses5
    nspr
    nss
    openssl
    pango
    pipewire
    saw-tools
    stdenv.cc.cc
    stdenv.cc.libc
    systemd
    vulkan-loader
    webkitgtk_6_0
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libxkbfile
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXtst
    zlib
  ];

  virtualisation.podman.enable = true;

  nix = {
    settings = {
      warn-dirty = false;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "${myOptions.username}" ];
      # substituters = [ "https://nix-gaming.cachix.org" "https://nixpkgs-python.cachix.org" "https://devenv.cachix.org" ];
      # trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  nixpkgs = {
    overlays = [
      #self.overlays.default
      inputs.nur.overlays.default
      # inputs.nix-vscode-extensions.overlays.default
      inputs.nix-vscode-extensions.overlays.default
    ];
  };
  
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  system.stateVersion = "25.05";
}
