{ pkgs, pkgsBundle, lib, ... }: {

  imports = []
    ++[(import ./blender.nix)];

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    arduino
    # bambu-studio
    pkgsBundle.pkgs-old.chromium
    clementine
    pkgsBundle.pkgs-stable.distrobox
    pkgsBundle.pkgs-main.gparted          # partition manager
    # kdenlive                              # Video editor
    lmstudio                              # GUI LLM interface
    nwg-look                              # GTK Config editor
    obs-studio                            # Screen recording and streaming
    ollama                                # LLM Backend
    pkgsBundle.pkgs-unstable.obsidian     # Notetaking software
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
    iperf3
    jq jqp                                # JSON Tools
    # lux                                 # Video Downloader
    libheif                               # Convert to and from HEIF files
    # mediainfo                           # Video file info
    nh
    nmap
    nixos-generators
    nixpkgs-review
    ntfs3g
    openssl
    openvpn
    osc                                   # Remote clipboard
    # ranger                              # CLI File Manager
    # scrot                               # CLI Screen Capture
    speedtest-cli
    stress
    swww
    tmux
    tree                                  # Show file tree
    unzip
    usbip-ssh                             # USB Port over SSH
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
    # twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    # (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ] ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));
}
