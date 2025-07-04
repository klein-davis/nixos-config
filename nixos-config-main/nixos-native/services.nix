{ ... }: 
{
  services = {
    seatd.enable = true;
    gvfs.enable = false;
    gnome.gnome-keyring.enable = false;
    dbus.enable = true;
    fstrim.enable = true;
  };
  services.udev.extraRules = ''
    KERNEL=="ttyACM[0-9]*",MODE="0666"
  '';
  # services.logind.extraConfig = ''
  #   # don’t shutdown when power button is short-pressed
  #   HandlePowerKey=ignore
  # '';

  # services.logind.extraConfig = ''
  #   HandlePowerKey=suspend
  #   IdleAction=suspend
  #   IdleActionSec=30m
  # '';
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';
  
}
