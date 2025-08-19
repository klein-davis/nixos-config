{ lib, pkgs, myOptions, ... }: 
{
  security.rtkit.enable = true;
  security.sudo.enable = true;
  security.polkit.enable = true; # Enabled by rtkit
  # security.pam.services.swaylock = { };
  security.pam.services.swaylock.text = lib.readFile "${pkgs.swaylock}/etc/pam.d/swaylock";
  # IDK
  # security.pam.services.swaylock.fprintAuth = false;
  security.sudo.extraRules = [
      {
          #users = [ "nixuser" ];
          commands = [
              {
                  command = "nixos-rebuild";
                  options = ["NOPASSWD"];
              }
          ];
      }
  ];
}
