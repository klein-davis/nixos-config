{ config, pkgs, myOptions, ... }: {
  environment.systemPackages = []
  ++ (if (myOptions.enable-rgb-lights) then [pkgs.openrgb-with-all-plugins] else []);
  services.hardware.openrgb.enable = myOptions.enable-rgb-lights; 

  # systemd.services.openrgb-resume = if myOptions.enable-rgb-lights then {
  #   description = "Reapply OpenRGB profile after resume from hibernate/suspend";
  #   wantedBy = [ "post-resume.target" ];
  #   after = [ "post-resume.target" ];
  #   script = ''
  #     ${pkgs.openrgb}/bin/openrgb --noautoconnect &
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "${myOptions.username}"; # Replace with your actual username
  #     # If you run OpenRGB as root for some devices, you might need to adjust this:
  #     # User = "root";
  #     # AmbientCapabilities = [ "CAP_SYS_RAWIO" ]; # Potentially needed for root
  #   };
  # } else {};

  # If you're encountering issues with OpenRGB not detecting devices
  # you may also need to ensure i2c-dev is loaded.
  # AMD : "i2c-piix4" Intel : "i2c-i801"
  # boot.kernelModules = [ "i2c-dev" "i2c-i801" ];
  # hardware.i2c.enable = true;
}