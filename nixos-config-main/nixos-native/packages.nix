{ pkgs, pkgsBundle, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    arduino
    blender
    pkgsBundle.pkgs-old.chromium
    clementine
    pkgsBundle.pkgs-stable.distrobox
    pkgsBundle.pkgs-stable.firefox
    gamescope
    pkgsBundle.pkgs-main.gparted          # partition manager
    kdenlive
    lmstudio
    neverball
    nwg-look
    obs-studio
    ollama
    pkgsBundle.pkgs-unstable.obsidian
    powertop
    qbittorrent
    qpwgraph
    # vcv-rack

    # CLI utils
    #atuin                                # Sync shell history
    bluez                                 # Bluetooth audio tools
    bluez-tools                           # Bluetooth audio tools
    # busybox                             # unused tools, remove if not needed for a while
    ddcutil                               # screen brightness
    fastfetch                             # fetch program
    file                                  # show filetype
    # lux                                 # Video Downloader
    libheif                               # Convert to and from HEIF files
    # mediainfo                           # Video file info
    nh
    nmap
    nix-index
    ntfs3g
    openssl
    openvpn
    # ranger                              # CLI File Manager
    # scrot                               # CLI Screen Capture
    swww
    tmux
    tree                                  # Show file tree
    unzip
    vim
    w3m  
    waypaper
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
  ];
}
