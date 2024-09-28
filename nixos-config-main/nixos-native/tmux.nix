{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "C-Space";
  }
}