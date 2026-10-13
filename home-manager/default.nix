{inputs, host, ...}: {
  imports =
       [(import ./bat.nix)]                       # better cat command
    ++ [(import ./bluetooth.nix)]                 # bluetooth config
    ++ [(import ./browser.nix)]                   # browser configs 
    ++ [(import ./btop.nix)]                      # resouces monitor 
    ++ [(import ./cava.nix)]                      # audio visualizer
    ++ [(import ./discord.nix)]                   # discord with catppuccin theme
    ++ [(import ./fastfetch)]                     # fastfetch config
    ++ [(import ./git.nix)]                       # version control
    ++ [(import ./gtk.nix)]                       # gtk theme
    ++ [(import ./hyprland)]                      # window manager
    ++ [(import ./hypridle.nix)]                  # idle
    ++ [(import ./kitty.nix)]                     # terminal
    ++ [(import ./nano.nix)]                      # nano editor config
    ++ [(import ./noctalia.nix)]                  # wayland shell/bar + theming
    ++ [(import ./nvim.nix)]                      # neovim editor
    ++ [(import ./packages.nix)]                  # other packages
    ++ [(import ./preactivation.nix)]             # fix gtk rebuild error
    ++ [(import ./rclone.nix)]                    # cloud storage sync
    ++ [(import ./style.nix)]                     # cursor/fonts/qt theming
    ++ [(import ./tmux.nix)]                      # terminal multiplexer
    ++ [(import ./vcv-rack.nix)]
    ++ [(import ./vscodium.nix)]                  # vscode
    ++ [(import ./zsh.nix)];                      # shell
}
