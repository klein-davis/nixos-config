{ inputs, pkgs, pkgs-main, ... }: 
{
  home.packages = (with pkgs; [
    bitwise                           # cli tool for bit / hex manipulation
    eza                               # ls replacement
    entr                              # perform action when file change
    fd                                # find replacement
    file                              # show file information 
    fzf                               # fuzzy finder
    gtt                               # google translate TUI
    gimp
    gtrash                            # rm replacement, put deleted files in system trash
    hexdump
    jdk17                             # java
    lazygit
    libreoffice
    nemo-with-extensions              # file manager
    nitch                             # systhem fetch util
    nix-prefetch-github
    prismlauncher                     # minecraft launcher
    ripgrep                           # grep replacement
    soundwireserver                   # pass audio to android phone
    todo                              # cli todo list
    toipe                             # typing test in the terminal
    valgrind                          # c memory analyzer
    yazi                              # terminal file manager
    #youtube-dl
    #zenity
    wdisplays
    wineWowPackages.wayland

    # Coding stuff
    gcc
    gnumake
    python3
    vscode
    devenv

    bleachbit                         # cache cleaner
    cmatrix
    pkgs-main.gparted                           # partition manager
    ffmpeg
    imv                               # image viewer
    killall
    libnotify
	  man-pages					            	  # extra man pages
    mpv                               # video player
    ncdu                              # disk space
    openssl
    pamixer                           # pulseaudio command line mixer
    pavucontrol                       # pulseaudio volume controle (GUI)
    playerctl                         # controller for media players
    wl-clipboard                      # clipboard utils for wayland (wl-copy, wl-paste)
    cliphist                          # clipboard manager
    poweralertd
    qalculate-gtk                     # calculator
    unzip
    wget
    xdg-utils
    xxd
    inputs.alejandra.defaultPackage.${system}
  ]);
}
