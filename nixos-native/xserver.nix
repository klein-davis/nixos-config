{ pkgs, myOptions, ... }: 
{
  services = {
  
    xserver = {
      enable = true;

      xkb.layout = "us";
      xkb.variant = "";

      videoDrivers = if (myOptions.enable-nvidia-gpu == true) then [ "nvidia" ] else []
      ++ (if (myOptions.enable-nvidia-gpu == true) then [ "amdgpu" ] else []);
      deviceSection = ''Option "TearFree" "True"'';
    };

    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad.accelProfile = "flat";
    };
    
  };

  # To prevent getting stuck at shutdown
  systemd.settings = {
    Manager = {
      DefaultTimeoutStopSec = "5s";
    };
  };

  # Enable the KDE Plasma Desktop Environment
  #services.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true; 


  # Enable the Hyperland Desktop Environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland";
}
