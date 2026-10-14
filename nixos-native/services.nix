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
      # Hand the power key entirely to Hyprland's XF86PowerOff bind (which
      # routes through "noctalia msg session lock-and-suspend") instead of
      # having logind suspend directly off the raw evdev event - otherwise
      # logind's own suspend races noctalia's lock-on-suspend handling.
      # See https://github.com/noctalia-dev/noctalia-shell/pull/2176#issuecomment-4060599828
      HandlePowerKey = "ignore";
    };
  };
  
}
