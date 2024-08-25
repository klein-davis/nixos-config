{ pkgs, pkgsBundle, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    arduino
    blender
    chromium
    clementine
    ddcutil
    firefox
    gamescope
    kdenlive
    pkgsBundle.pkgs-main.lmstudio
    nmap
    obs-studio
    pkgsBundle.pkgs-unstable.obsidian
    powertop
    qpwgraph

    # CLI utils
    #atuin
    #bluez
    #bluez-tools
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
    feh
    gromit-mpx
    screenkey

    # CLI Toys
    cowsay
    kittysay
    ponysay
    pokemonsay
    charasay
    
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
