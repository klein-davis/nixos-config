{ lib, pkgs, myOptions, ... }: 
{
  security.rtkit.enable = true;
  security.polkit.enable = true; # Enabled by rtkit

  security.sudo.enable = false;
  security.sudo-rs.enable = true;
  security.sudo-rs.execWheelOnly = true;

  # security.pam.services.swaylock = { };
  security.pam.services.swaylock.text = lib.readFile "${pkgs.swaylock}/etc/pam.d/swaylock";

  security.pam.services.swaylock.fprintAuth = false;

  # security.sudo.extraRules = [
  #   {
  #     #users = [ "nixuser" ];
  #       commands = [
  #       {
  #         command = "nixos-rebuild";
  #         options = ["NOPASSWD"];
  #       }
  #     ];
  #   }
  # ];
}
