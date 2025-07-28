{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = false;
  };
  # z-lua remember cd commands
  # telescope
  # ripgrep
}
