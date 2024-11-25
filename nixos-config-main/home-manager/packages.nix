{ inputs, pkgs, pkgsBundle, myOptions, ... }: 
{
  home.packages = (with pkgs; [
    # atop
    bitwise                               # cli tool for bit / hex manipulation
    # pkgsBundle.pkgs-super-old.cgminer
    # cgminer
    dust
    eza                                   # ls replacement
    entr                                  # perform action when file change
    fd                                    # find replacement
    file                                  # show file information 
    freecad
    gtt                                   # google translate TUI
    gimp
    gtrash                                # rm replacement, put deleted files in system trash
    hexdump
    jdk17                                 # java
    lazygit
    pkgsBundle.pkgs-stable.libreoffice
    nemo-with-extensions                  # file manager
    nitch                                 # systhem fetch util
    nix-prefetch-github
    #(prismlauncher.override               # minecraft launcher
    #{ withWaylandGLFW = true; })
    prismlauncher
    ripgrep                               # grep replacement
    soundwireserver                       # pass audio to android phone
    todo                                  # cli todo list
    toipe                                 # typing test in the terminal
    ttyper
    udiskie
    valgrind                              # c memory analyzer
    # yazi                                  # terminal file manager
    #youtube-dl
    #zenity
    wdisplays
    # writedisk
    wineWowPackages.wayland

    # Coding stuff
    clang-tools
    # clang
    gcc
    gdb
    # cmake
    # gnumake
    # python3
    vscode
    devenv

    # bleachbit                             # cache cleaner
    cmatrix
    ffmpeg
    fzf
    imv                                   # imageviewer
    killall
    libnotify
	  man-pages					            	      # extra man pages
    mpv                                   # vide player
    ncdu                                  # disk space
    openssl
    pamixer                               # pulseaudo command line mixer
    pavucontrol                           # pulseaudio volume controle (GUI)
    playerctl                             # controller for media players
    wl-clipboard                          # clipoard utils for wayland (wl-copy, wl-paste)
    cliphist                              # clipboard manager
    poweralertd
    qalculate-gtk                         # calculato
    unzip
    wget
    xdg-utils
    xxd
    inputs.alejandra.defaultPackage.${myOptions.system}
  ]);
}
