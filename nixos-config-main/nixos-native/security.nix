{ lib, pkgs, ... }: 
{
  security.rtkit.enable = true;
  security.sudo.enable = true;
  # security.polkit.enable = true; # Enabled by rtkit
  # security.pam.services.swaylock = { };
  security.pam.services.swaylock.text = lib.readFile "${pkgs.swaylock}/etc/pam.d/swaylock";
  # IDK
  # security.pam.services.swaylock.fprintAuth = false;
  # security.sudo.extraRules = [
  #     {
  #         users = [ "YOUR_USERNAME" ];
  #         commands = [
  #             {
  #                 command = "gpu-screen-recorder";
  #                 options = ["NOPASSWD"];
  #             }
  #         ];
  #     }
  # ]
}
