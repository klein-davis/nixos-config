{ pkgs, config, inputs, ... }: 
{
  home.packages = with pkgs;[
    ## Utils
    # winetricks
    # inputs.nix-gaming.packages.${pkgs.system}.wine-ge

    ## Cli games
    _2048-in-terminal
    vitetris
    nethack

    ## Emulation
    dosbox-x
    sameboy
    snes9x
    cemu
    dolphin-emu
  ];
}
