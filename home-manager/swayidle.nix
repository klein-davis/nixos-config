{ pkgs, lib, config, inputs, ... }: 
{
  service.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 30; # 5 minutes
        command = "${pkgs.swaylock-effects}/bin/swaylock";
        # Optional: resumeCommand = "pkill swaylock";
      }
      {
        timeout = 60; # 10 minutes
        command = "${pkgs.wayland-utils}/bin/wlr-randr --output 'eDP-1' --off"; # Turn off screen
        resumeCommand = "${pkgs.wayland-utils}/bin/wlr-randr --output 'eDP-1' --on"; # Turn screen back on
      }
    ];

    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock-effects}/bin/swaylock";
      }
      # Add more events if needed, e.g., to run a script on lock/unlock
    ];
  };
}
