{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = false;
  };
}
