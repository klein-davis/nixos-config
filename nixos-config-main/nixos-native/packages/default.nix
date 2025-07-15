{ pkgs, pkgsBundle, lib, ... }: {

  imports = []
    ++[(import ./blender.nix)];

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    arduino
    pkgsBundle.pkgs-old.chromium
    clementine
    pkgsBundle.pkgs-stable.distrobox
    # pkgsBundle.pkgs-stable.firefox
    # firefox
    pkgsBundle.pkgs-main.gparted          # partition manager
    # kdenlive
    lmstudio
    neverball
    nwg-look
    obs-studio
    ollama
    pkgsBundle.pkgs-unstable.obsidian
    powertop
    qbittorrent
    qpwgraph
    viewnior

    # CLI utils
    bluez                                 # Bluetooth audio tools
    bluez-tools                           # Bluetooth audio tools
    busybox                               # unused tools, remove if not needed for a while
    ddcutil                               # screen brightness
    fastfetch                             # fetch program
    file                                  # show filetype
    foot
    gettext
    # lux                                 # Video Downloader
    libheif                               # Convert to and from HEIF files
    # mediainfo                           # Video file info
    nh
    nmap
    nixos-generators
    ntfs3g
    openssl
    openvpn
    # ranger                              # CLI File Manager
    # scrot                               # CLI Screen Capture
    stress
    swww
    tmux
    tree                                  # Show file tree
    unzip
    vim
    w3m  
    waypaper
    waypipe
    wayvnc
    wgcf
    wget
    yt-dlp
    zip
    zram-generator

    # GUI utils
    feh
    gromit-mpx
    screenkey
    
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    # (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ] ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));
}
