{ pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.nixosModules.stylix ];
  stylix.base16Scheme = {
    base00 = "101010";
    base01 = "686868";
    base02 = "525252";
    base03 = "686868";
    base04 = "868686";
    base05 = "8E8E8E";
    base06 = "747474";
    base07 = "7C7C7C";
    base08 = "F7F7F7";
    base09 = "A0A0A0";
    base0A = "868686";
    base0B = "8E8E8E";
    base0C = "747474";
    base0D = "7C7C7C";
    base0E = "B9B9B9";
    base0F = "A0A0A0";
  };

  stylix.image = "~/Pictures/wallpapers/wallpaper.png";
}