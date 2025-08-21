{ pkgs, ... }: 
{
  services = {
    seatd.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = false;
    dbus.enable = true;
    fstrim.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    envfs.enable = true;
  };
  
  environment.systemPackages = with pkgs; [gvfs];
  services.udev.extraRules = ''
    KERNEL=="ttyACM[0-9]*",MODE="0666"
  '';
  
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';  
  
}
