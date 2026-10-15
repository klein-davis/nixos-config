# Home Assistant MQTT bridge for this laptop (battery/brightness/CPU sensors
# over MQTT). Laptop-only: desktop/vm hosts have no battery or backlight to
# report, so this only enables on "framework1".
{ inputs, host, lib, config, myOptions, ... }:
{
  imports = [ inputs.ha-linux-agent.homeManagerModules.default ];

  config = {
    services.ha-linux-agent = {
      enable = true;

      settings = {
        device.name = myOptions.hostname;

        mqtt = {
          host = "homeassistant.tailf1460c.ts.net";
          port = 1883;
          username = "mqtt-user-1";
          password_file = "${config.home.homeDirectory}/.config/ha-linux-agent/mqtt-password";
          # Don't gap history graphs when the agent disconnects (laptop
          # asleep, network drop) -- sensors just hold their last value
          # instead of going "unavailable". Override per-entity with
          # `availability = true` on any sensor that should still tell
          # the truth about being unreachable (e.g. a session_status
          # sensor).
          availability = false;
        };

        number = []
        ++ (if (host == "framework1") then [
          {
            id = "brightness";
            read_command = "brightnessctl -m | cut -d, -f4 | tr -d '%'";
            set_command = "brightnessctl set {value}%";
            min = 0;
            max = 100;
            step = 5;
            interval = "5s";
          }] else []);

        sensor = [
          {
            id = "cpu_usage";
            builtin = "cpu_usage";
            unit = "%";
            interval = "5s";
          }
          {
            id = "uptime";
            builtin = "uptime";
            unit = "s";
            device_class = "duration";
            interval = "60s";
          }
        ]
        ++ (if (host == "framework1") then [
          {
            id = "battery_percent";
            builtin = "battery_percent";
            unit = "%";
            device_class = "battery";
            interval = "30s";
          }
        ] else []);

        binary_sensor = []
        ++ (if (host == "framework1") then [
          {
            id = "charging";
            builtin = "charging";
            device_class = "battery_charging";
          }
        ] else []);

        # Shows up in HA as notify.alert -- callable from automations via
        # `action: notify.send_message`, `target: {entity_id: notify.alert}`.
        # Delivers via notify-send to whatever's listening on the session's
        # notification bus (noctalia's notification daemon here).
        notify = [
          {
            id = "alert";
            app_name = "Home Assistant";
            expire_ms = 5000;
          }
        ];
      };
    };

    # Not managed by home-manager (home.file would land it in the Nix
    # store, which is world-readable): create it once by hand and drop
    # the real MQTT password in, e.g.:
    #   mkdir -p -m 700 ~/.config/ha-linux-agent
    #   printf '%s' 'your-real-password' > ~/.config/ha-linux-agent/mqtt-password
    #   chmod 600 ~/.config/ha-linux-agent/mqtt-password
  };
}
