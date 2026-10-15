{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-f";
    mouse = true;
    historyLimit = 10000;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          # Optional: restore vim/nvim sessions too
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }

      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'off'
          set -g @continuum-save-interval '1'  # save every 1 minutes
        '';
      }

      # fuzzback
      # harpoon
    ];
  };
}