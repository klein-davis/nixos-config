{ ... }: 
{
  services = {
    seatd.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
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
  
}
