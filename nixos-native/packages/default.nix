{ inputs, myOptions, pkgs, pkgsBundle, lib, host, ... }: {

  imports = []
    ++ [(import ./blender.nix)]                     # 3D modeling/animation suite
    ++ [(import ./deskflow.nix)]                    # Share mouse/keyboard across computers
    ++ [(import ./docker.nix)]                      # Container runtime
    ++ [(import ./flatpak.nix)]                     # Flatpak sandboxed app support
    ++ [(import ./lmstudio.nix)]                    # LM Studio programs
    ++ [(import ./openrgb.nix)]                     # OpenRGB for lighting control
    ++ [(import ./steam.nix)]                       # Steam integration
    ++ [(import ./wireshark.nix)]                   # Network protocol analyzer
    ;

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.udev.packages = with pkgs; [ arduino ];

  environment.systemPackages = with pkgs; [
    # Test
    atopile                               # Design circuit boards with code
    gsettings-desktop-schemas             # GSettings schemas for desktop components
    pv
    pvetui
    # Bitwarden test
    bws
    bitwarden-desktop
    bitwarden-cli

    # Desktop apps
    arduino-ide                           # Arduino IDE
    pkgsBundle.pkgs-old.chromium          # Chromium Web Browser
    easyeffects                           # Audio effects for PipeWire
    en-croissant                          # Chess GUI/toolkit
    pkgsBundle.pkgs-stable.freecad        # 3D CAD modeler (unstable fails to build ifcopenshell/boost)
    fretboard                             # Guitar chord lookup
    ghidra                                # Software reverse engineering suite
    pkgsBundle.pkgs-stable.gimp           # Image editor
    gnome-sound-recorder                  # Simple sound recorder
    google-chrome                         # Proprietary Web Browser
    gparted                               # Partition manager
    kicad                                 # Electronics design (EDA) suite
    libreoffice                           # Office productivity suite
    linux-wifi-hotspot                    # GUI hotspot creator
    lmstudio                              # GUI LLM interface
    localsend                             # Cross-platform AirDrop alternative
    mission-center                        # CPU/Mem/Disk/Network/GPU monitor
    mission-planner                       # ArduPilot ground station
    musescore                             # Music notation software
    nemo                                  # file manager
    nwg-look                              # GTK Config editor
    obsidian                              # Notetaking software
    # orca-slicer                           # 3D Printer Slicer
    pavucontrol                           # pulseaudio volume controle (GUI)
    prismlauncher                         # minecraft launcher
    pkgsBundle.pkgs-stable.qalculate-gtk  # calculator
    qdirstat                              # Graphical disk usage analyzer
    qpwgraph                              # Audio Routing Software
    # reaper
    remmina                               # RDP Client
    rpi-imager                            # Raspberry Pi imaging utility
    pkgsBundle.pkgs-stable.rustdesk       # Open source remote desktop
    viewnior                              # Image Viewer
    wdisplays                             # Wayland display configuration GUI
    winboat                               # Run Windows apps on Linux

    # CLI utils
    inputs.alejandra.defaultPackage.${myOptions.system}  # Nix code formatter
    alsa-utils                            # ALSA sound utilities
    bitwise                               # cli tool for bit / hex manipulation
    bleachbit                             # cache cleaner
    bluetuith                             # TUI for bluetooth connections
    bluez                                 # Bluetooth audio tools
    bluez-tools                           # Bluetooth audio tools
    busybox                               # unused tools, remove if not needed for a while
    caligula                              # TUI iso flasher
    cliphist                              # clipboard manager
    cloc                                  # Count lines of code
    cmatrix                               # Matrix-style falling characters
    ddcutil                               # Screen brightness
    devenv                                # Reproducible dev environments
    dig                                   # DNS lookup tool
    distrobox                             # Containerized Linux distros via podman/docker
    dust                                  # Intuitive disk usage (du replacement)
    entr                                  # perform action when file change
    entropy                               # Scan codebase for secrets/high-entropy lines
    eza                                   # ls replacement
    fastfetch                             # Fetch program
    fd                                    # find replacement
    ffmpeg                                # Audio/video conversion and streaming
    file                                  # show file information
    foot                                  # Terminal Emulator
    fzf                                   # Fuzzy finder
    gettext                               # Translation Tools
    gh                                    # GitHub CLI
    git                                   # Version Controll
    git-lfs                               # Git extension for large files
    glib                                  # Core GLib C library
    gtrash                                # rm replacement, put deleted files in system trash
    gtt                                   # google translate TUI
    hexdump                               # Hex viewer (util-linux)
    imv                                   # Image Viewer
    iperf3                                # Client to Client bandwidth tester
    jq jqp                                # JSON Tools
    killall                               # Kill processes by name (psmisc)
    lavat                                 # Lava lamp simulation in the terminal
    libcaca                               # Text-mode graphics library
    libnotify                             # Send desktop notifications
    lux                                   # Video Downloader
    mediainfo                             # Video file info
    mpv                                   # vide player
    ncdu                                  # disk space
    nh                                    # Usefull Nix Tools
    nitch                                 # systhem fetch util
    nix-prefetch-github                   # Prefetch sources from GitHub
    nixos-generators                      # Build NixOS images (ISO, qcow2, etc.)
    nixpkgs-review                        # Used to review nixpkgs pr's
    nmap                                  # Network Scanning Tool
    ntfs3g                                # NTFS drivers?
    opencode                              # AI coding agent for the terminal
    openssl                               # TLS/SSL cryptography library
    osc                                   # Remote clipboard
    p7zip                                 # Command line 7-Zip archiver
    pamixer                               # Pulseaudio CLI mixer
    playerctl                             # controller for media players
    poweralertd                           # UPower-based battery alerts
    qlcplus                               # Open Source DMX Controller
    ripgrep                               # grep replacement
    scope-tui                             # Terminal Oscilloscope
    ser2net                               # Serial connections over IP
    speedtest-cli                         # Internet Speedtesting tool
    stress                                # Benchmark workload generator
    timidity                              # Terminal MIDI player
    tmux                                  # Terminal Multiplexer
    todo                                  # cli todo list
    tree                                  # Show file tree
    ttyper                                # Terminal typing test
    udiskie                               # Removable disk automounter
    unrar                                 # Utility for RAR archives
    unzip                                 # Extract .zip archives
    usbip-ssh                             # USB Port over SSH
    valgrind                              # c memory analyzer
    w3m                                   # Text-mode web browser
    waypaper                              # GUI wallpaper setter for Wayland
    waypipe                               # Network proxy for Wayland apps
    wayvnc                                # VNC server for wlroots compositors
    wev                                   # Wayland event viewer
    wgcf                                  # Unofficial Cloudflare Warp CLI
    wget                                  # Download files over HTTP/HTTPS/FTP
    wiremix                               # Simple TUI mixer for PipeWire
    wl-clipboard                          # clipoard utils for wayland (wl-copy, wl-paste)
    xdg-utils                             # Desktop integration CLI tools
    xxd                                   # Hex dump tool
    yazi                                  # terminal file manager
    yt-dlp                                # Video/audio downloader
    zenity                                # Display dialogs from shell scripts
    zip                                   # Create/modify zip archives
    zram-generator                        # Systemd zram swap generator
    zsh-fzf-tab                           # Fuzzy tab completion for zsh

    # Background stuff
    python315                             # Python interpreter

    # Games
    ## Utils
    protonplus                            # Wine/Proton compatibility tools manager
    # winetricks

    ## Cli games
    _2048-in-terminal                     # 2048 game in the terminal
    nethack                               # Roguelike dungeon crawler
    vitetris                              # Terminal Tetris clone

    ## Emulation
    # cemu
    dolphin-emu                           # GameCube/Wii emulator
    dosbox-x                              # DOS emulator
    pkgsBundle.pkgs-unstable.eden         # Switch emulator
    sameboy                               # Game Boy/Game Boy Color emulator
    snes9x                                # SNES emulator
  ];

  fonts.packages = with pkgs; [
    font-awesome                          # Icon font
    nerd-fonts.jetbrains-mono             # JetBrains Mono Nerd Font
    # jetbrains-mono
    pkgsBundle.pkgs-old.nerdfonts         # Legacy full Nerd Fonts bundle
    # (pkgsBundle.pkgs-old.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    noto-fonts                            # Broad-coverage Noto font family
    powerline-fonts                       # Powerline-patched fonts
    powerline-symbols                     # Powerline glyph/symbol font
  ];
}
