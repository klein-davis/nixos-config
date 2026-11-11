{ ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = false;
    withPython3 = true;
    withRuby = false;
  };
  # z-lua remember cd commands
  # telescope
  # ripgrep
}
