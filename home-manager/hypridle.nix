{ config, lib, pkgs, ... }: 
let
  cfg = config.custom.services.hypridle;
in {
  options = {
    custom.services.hypridle.enable = lib.mkEnableOption "enable hypridle service";
  };

  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          #lock_cmd = "pidof hyprlock || hyprlock";
          lock_cmd = "swaylock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          # lockscreen
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          # turn monitor off
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          # enter hybrid sleep
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}