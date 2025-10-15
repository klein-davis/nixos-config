{ pkgs, config, ... }: 
{
  imports = [
    ./hardware-configuration.nix
    ./../../nixos-native/default.nix
  ];

  services.logind = {
    settings.Login = {
      # Action when the lid is closed, regardless of power state
      HandleLidSwitch = "ignore";
      
      # Action when the lid is closed and on external power (AC)
      HandleLidSwitchExternalPower = "ignore";
      
      # Action when the lid is closed and docked (if applicable)
      HandleLidSwitchDocked = "ignore";
    };
  };

  # Define the udev rules to restart the logind service.
  # This is the correct NixOS way to handle udev rules.
  # services.udev.extraRules = ''
  #   ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.systemd}/bin/systemctl restart logind-lid-ac"
  #   ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.systemd}/bin/systemctl restart logind-lid-battery"
  # '';

  # # Configure custom lid behavior based on power state.
  # systemd.services.logind-lid-override = {
  #   description = "Override logind lid switch behavior based on power source";
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.acpi ];
  #   script = ''
  #     # Create the directory first.
  #     mkdir -p /etc/systemd/logind.conf.d/

  #     # The lidswitch configuration for when we are charging.
  #     echo "HandleLidSwitch=ignore" > /etc/systemd/logind.conf.d/ac.conf

  #     # The lidswitch configuration for when we are on battery.
  #     echo "HandleLidSwitch=suspend" > /etc/systemd/logind.conf.d/battery.conf

  #     # Set the initial configuration based on the current power state.
  #     if acpi -a | grep -q "on-line"; then
  #       cp /etc/systemd/logind.conf.d/ac.conf /etc/systemd/logind.conf.d/lid.conf
  #     else
  #       cp /etc/systemd/logind.conf.d/battery.conf /etc/systemd/logind.conf.d/lid.conf
  #     fi
  #   '';
  # };

  # # Define the services that will be triggered by the udev rules.
  # systemd.services.logind-lid-ac = {
  #   description = "Set logind to ignore lid switch on AC power";
  #   script = "cp /etc/systemd/logind.conf.d/ac.conf /etc/systemd/logind.conf.d/lid.conf";
  #   path = [ pkgs.systemd ];
  #   serviceConfig.Type = "oneshot";
  # };

  # systemd.services.logind-lid-battery = {
  #   description = "Set logind to suspend on lid switch on battery power";
  #   script = "cp /etc/systemd/logind.conf.d/battery.conf /etc/systemd/logind.conf.d/lid.conf";
  #   path = [ pkgs.systemd ];
  #   serviceConfig.Type = "oneshot";
  # };
}
