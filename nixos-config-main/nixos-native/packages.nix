{ pkgs, pkgsBundle, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    #permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0"];
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    arduino
    blender
    clementine
    firefox
    kdenlive
    obs-studio
    pkgsBundle.pkgs-unstable.obsidian
    pcmanfm-qt
    powertop
    ddcutil
    qpwgraph

    pkgsBundle.pkgs-main.lmstudio

    nmap

    # CLI utils
    atuin
    bluez
    bluez-tools
    fastfetch
    file
    lux
    mediainfo
    nix-index
    ntfs3g
    openssl
    ranger
    scrot
    swww
    tmux
    tree
    unzip
    w3m
    wget
    yt-dlp
    zip
    zram-generator

    # GUI utils
    #dmenu
    feh
    gromit-mpx
    screenkey

    #rocm-opencl-icd
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
