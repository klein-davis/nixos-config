{ inputs, pkgs, pkgsBundle, myOptions, ... }: 
{
  home.packages = (with pkgs; [
    # atop
    audio-recorder
    bitwise                               # cli tool for bit / hex manipulation
    # (pkgs.bottles.override { removeWarningPopup = true; })
    # pkgsBundle.pkgs-super-old.cgminer
    # cgminer
    cloc
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
    # lazygit
    linux-wallpaperengine
    pkgsBundle.pkgs-stable.libreoffice
    nemo                                  # file manager
    nitch                                 # systhem fetch util
    nix-prefetch-github
    #(prismlauncher.override               # minecraft launcher
    #{ withWaylandGLFW = true; })
    prismlauncher
    ripgrep                               # grep replacement
    # rstudio
    soundwireserver                       # pass audio to android phone
    todo                                  # cli todo list
    toipe                                 # typing test in the terminal
    ttyper
    udiskie
    valgrind                              # c memory analyzer
    yazi                                  # terminal file manager
    #zenity
    wdisplays
    # writedisk
    wineWowPackages.wayland

    # Coding stuff
    # These should be added on a per-project basis with flakes
    # clang-tools
    # clang
    gcc
    gdb
    # jdk17                                 # java
    # cmake
    # gnumake
    # python3
    devenv
    # pkgsBundle.pkgs-unstable.devenv
    # direnv

    # CLI
    # bleachbit                             # cache cleaner
    cmatrix
    ffmpeg
    fzf
    zsh-fzf-tab
    imv                                   # imageviewer
    killall
    libcaca
    libnotify
	  man-pages					            	      # extra man pages
    mpv                                   # vide player
    ncdu                                  # disk space
    nmap
    openssl
    pavucontrol                           # pulseaudio volume controle (GUI)
    playerctl                             # controller for media players
    wl-clipboard                          # clipoard utils for wayland (wl-copy, wl-paste)
    cliphist                              # clipboard manager
    poweralertd
    qalculate-gtk                         # calculator
    unzip
    wget
    xdg-utils
    xxd
    inputs.alejandra.defaultPackage.${myOptions.system}
  ]);
}
