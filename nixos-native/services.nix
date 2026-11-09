{ pkgs, host, ... }: 
{
  services = {
    dbus.enable = true;
    fstrim.enable = true;
    fwupd.enable = (host == "framework1");
    gnome.gnome-keyring.enable = false;
    gvfs.enable = true;
    seatd.enable = true;
    printing.enable = true;
    envfs.enable = true;
    udisks2.enable = true;
  };
  
  environment.systemPackages = with pkgs; [gvfs];
  services.udev.extraRules = ''
    KERNEL=="ttyACM[0-9]*",MODE="0666"
    # ESP32 / Arduino / Common Serial
    KERNEL=="ttyACM*", MODE="0666", GROUP="dialout"
    KERNEL=="ttyUSB*", MODE="0666", GROUP="dialout"
  '';
  
  services.logind.settings = {
    Login = {
      HandlePowerKey = "suspend";
    };
  };

  # Kernel 6.18.57 ships tiny_power_button, which signals systemd to power off on
  # every power-key press before logind/Hyprland can handle it.
  boot.blacklistedKernelModules = [ "tiny_power_button" ];

}
