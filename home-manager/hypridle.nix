{ pkgs, lib, myOptions, ... }:
let
  power = myOptions.power;
  dpmsWakeScript = import ./scripts/hypr-dpms-wake.nix { inherit pkgs; };
  dpmsWake = "${dpmsWakeScript}/bin/hypr-dpms-wake";
in
{
  config = {
    services.hypridle = {
      enable = power.idle-lock != 0 || power.idle-dim != 0 || power.idle-sleep != 0;
      settings = {
        general = {
          lock_cmd = "noctalia msg session lock";
          before_sleep_cmd = "loginctl lock-session; ${pkgs.brightnessctl}/bin/brightnessctl -s -c backlight";
          # amdgpu's backlight resets to 0 on resume independent of the DPMS
          # state, so the dpms-on dispatch alone leaves the panel dark -
          # restore the pre-sleep brightness alongside it. dpmsWake also
          # forces a full output disable/re-enable after "on" so external
          # DP monitors that failed to renegotiate EDID during sleep don't
          # come back at a fallback resolution.
          # hypridle's idle-dim listener keeps counting through suspend, so
          # if the system sleeps longer than idle-dim's timeout, on-timeout
          # (dpms off) fires again right after this on-resume sequence.
          # Restarting the service resets its idle timers so that doesn't
          # happen.
          after_sleep_cmd = "${dpmsWake} on after-sleep ; ${pkgs.brightnessctl}/bin/brightnessctl -r -c backlight ; ${pkgs.systemd}/bin/systemctl --user restart hypridle.service";
        };

        listener =
          (lib.optional (power.idle-lock != 0) {
            # lockscreen
            timeout = power.idle-lock;
            on-timeout = "loginctl lock-session";
          })
          ++ (lib.optional (power.idle-dim != 0) {
            # turn monitor off
            timeout = power.idle-dim;
            on-timeout = "${dpmsWake} off idle-timeout";
            on-resume = "${dpmsWake} on idle-resume";
          })
          ++ (lib.optional (power.idle-sleep != 0) {
            # suspend if idle and on battery
            timeout = power.idle-sleep;
            on-timeout = "${pkgs.writeShellScript "suspend-if-unplugged" ''
              ${pkgs.acpi}/bin/acpi -a | grep -q off-line && ${pkgs.systemd}/bin/systemctl suspend
            ''}";
          });
      };
    };
  };
}
