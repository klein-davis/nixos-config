{ pkgs, pkgsBundle, lib, ... }: {

  imports = []
    ++ [(import ./blender.nix)]
    ++ [(import ./steam.nix)]                       # Steam integration
    ++ [(import ./openrgb.nix)];          # OpenRGB for lighting control

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.udev.packages = with pkgs; [ arduino ];

  environment.systemPackages = with pkgs; [
    # Desktop apps
    arduino-ide                           # Arduino IDE
    bambu-studio
    pkgsBundle.pkgs-old.chromium          # Chromium Web Browser
    clementine                            # Music Player
    pkgsBundle.pkgs-stable.distrobox
    google-chrome                         # Proprietary Web Browser
    gparted                               # Partition manager
    kicad
    linux-wifi-hotspot                    # GUI hotspot creator
    lmstudio                              # GUI LLM interface
    nwg-look                              # GTK Config editor
    obs-studio                            # Screen recording and streaming
    ollama                                # LLM Backend
    openrocket                            # Rocket Simulator
    orca-slicer                           # 3D Printer Slicer
    pkgsBundle.pkgs-unstable.obsidian     # Notetaking software
    qbittorrent                           # Torrenting
    qpwgraph                              # Audio Routing Software
    viewnior                              # Image Viewer

    # CLI utils
    bluez                                 # Bluetooth audio tools
    bluez-tools                           # Bluetooth audio tools
    busybox                               # unused tools, remove if not needed for a while
    caligula                              # TUI iso flasher
    ddcutil                               # Screen brightness
    fastfetch                             # Fetch program
    file                                  # Show filetype
    foot                                  # Terminal Emulator
    # gettext                               # Translation Tools
    git                                   # Version Controll
    iperf3                                # Client to Client bandwidth tester
    jq jqp                                # JSON Tools
    # lux                                 # Video Downloader
    libheif                               # Convert to and from HEIF files
    # mediainfo                             # Video file info
    nh                                    # Usefull Nix Tools
    nmap                                  # Network Scanning Tool
    nixos-generators
    nixpkgs-review                        # Used to review nixpkgs pr's
    ntfs3g                                # NTFS drivers?
    # openssl
    # openvpn
    osc                                   # Remote clipboard
    # ranger                              # CLI File Manager
    # scrot                               # CLI Screen Capture
    speedtest-cli                         # Internet Speedtesting tool
    stress                                # Benchmark workload generator
    # swww                                  # Wallpaper?
    tmux                                  # Terminal Multiplexer
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
    # feh
    # gromit-mpx
    # screenkey
    python3
    
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
