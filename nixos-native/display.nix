{ pkgs, myOptions, ... }: 
{
  services = {
    xserver = {
      enable = true;

      xkb.layout = "us";
      xkb.variant = "";

      videoDrivers = if (myOptions.enable-nvidia-gpu == true) then [ "nvidia" ] else []
      ++ (if (myOptions.enable-amd-gpu == true) then [ "amdgpu" ] else []);
      deviceSection = ''Option "TearFree" "True"'';
    };

    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad.accelProfile = "flat";
    };
  };
  
  services.desktopManager.plasma6.enable = true;

  # Enable the Hyperland Desktop Environment
  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };
}
