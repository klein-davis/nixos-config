{ inputs, pkgs, ...}: 
{
  home.packages = with pkgs; [
    # swww
    swaybg
    inputs.hypr-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
    hyprpicker
    grim
    slurp
    swappy
    wl-clip-persist
    wf-recorder
    wayland
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
      inputs.hyprgrass.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
