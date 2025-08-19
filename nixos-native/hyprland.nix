{ config, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      # pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
      # pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-gnome
    ];
  };
}
