{ config, pkgs, myOptions, ... }: {
    environment.systemPackages = []
    ++ (if (myOptions.enable-rgb-lights) then [pkgs.openrgb-with-all-plugins] else []);
    services.hardware.openrgb.enable = myOptions.enable-rgb-lights; 
}