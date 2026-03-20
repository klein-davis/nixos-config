{ pkgs, ... }: 
{
  services = {
    dbus.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    gnome.gnome-keyring.enable = false;
    gvfs.enable = true;
    seatd.enable = true;
    printing.enable = true;
    envfs.enable = true;
    flatpak.enable = true;
  };
  
  environment.systemPackages = with pkgs; [gvfs];
  services.udev.extraRules = ''
    KERNEL=="ttyACM[0-9]*",MODE="0666"
  '';
  
  services.logind.settings = {
    Login = {
      HandlePowerKey = "suspend";
    };
  };
  
}
