{inputs, host, ...}: {
  imports =
      #  [(import ./audacious/audacious.nix)]       # music player
       [(import ./bat.nix)]                       # better cat command
    ++ [(import ./browser.nix)]                   # browser configs 
    ++ [(import ./btop.nix)]                      # resouces monitor 
    ++ [(import ./cava.nix)]                      # audio visualizer
    ++ [(import ./discord.nix)]                   # discord with catppuccin theme
    ++ [(import ./fastfetch.nix)]                 # fastfetch config
    # ++ [(import ./floorp/floorp.nix)]             # firefox based browser
    ++ [(import ./gaming.nix)]                    # packages related to gaming
    ++ [(import ./git.nix)]                       # version control
    ++ [(import ./gtk.nix)]                       # gtk theme
    ++ [(import ./hyprland)]                      # window manager
    ++ [(import ./hypridle.nix)]                  # idle
    ++ [(import ./kitty.nix)]                     # terminal
    ++ [(import ./mako.nix)]                      # notification deamon
    # ++ [(import ./micro.nix)]                     # nano replacement
    ++ [(import ./nano.nix)]
    ++ [(import ./nvim.nix)]                      # neovim editor
    ++ [(import ./packages.nix)]                  # other packages
    ++ [(import ./preactivation.nix)]             # fix gtk rebuild error
    ++ [(./rclone.nix)]
    # ++ [(import ./scripts/scripts.nix)]           # personal scripts
    ++ [(import ./stylix.nix)]
    ++ [(import ./swaylock.nix)]                  # lock screen
    ++ [(import ./tmux.nix)]                      #
    ++ [(import ./vscodium.nix)]                  # vscode
    ++ [(import ./waybar)]                        # status bar
    ++ [(import ./wofi.nix)]                      # launcher
    ++ [(import ./zsh.nix)];                      # shell
}
