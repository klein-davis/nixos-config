# home-manager/modules/nano-config.nix
{ config, pkgs, ... }:

{
  
  home.file.".nanorc".text = ''
    # Your nano configuration goes here
    set tabsize 2
    set tabstospaces
    # set softwrap
    # set linenumbers
    # include "${pkgs.nano}/share/nano/*.nanorc" # This line includes default syntax highlighting if you want it
    # include "${pkgs.nano}/share/nano/extra/*.nanorc"
  '';
}
