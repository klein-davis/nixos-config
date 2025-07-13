{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-f";
  };
}