{ myOptions, ... }: 
{
  stylix = {
    # autoEnable = false;
    targets = {
      kitty.enable = true;
      hyprland.enable = false;
      mako.enable = true;
      swaylock.enable = true;
      waybar.enable = false;
      kde.enable = true;
      vscode.enable = true;
      gnome.enable = false;
      firefox = {
        enable = true; # Make sure this is here!
        profileNames = [ myOptions.username ];
      };
    };

    
  };
}