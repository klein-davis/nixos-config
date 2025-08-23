{ pkgs, config, myOptions, ... }: {

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = if ! myOptions.power.mobile then
      "performance"
    else 
      # cpuFreqGovernor = lib.mkDefault "ondemand";
      "ondemand";
  };

  services.power-profiles-daemon.enable = false;
  services.tlp = if myOptions.power.mobile then {
    enable = true;
    settings = {
      # When on battery power, use the powersave governor.
      # CPU_GOVERNOR_ON_BAT = "powersave";
      # When on AC power, use the performance governor.
      # CPU_GOVERNOR_ON_AC = "performance";
      
      # Additional settings for AC vs Battery
      # CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      # CPU_ENERGY_PERF_POLICY_ON_AC = "performance"
      
      # You can also configure other aspects like USB autosuspend
      # USB_AUTOSUSPEND_ON_BAT = 1;

      # USB_AUTOSUSPEND_ON_AC = 0;


      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  } else {};
  
  # mobile = true
  environment = if myOptions.power.mobile then {

  #   Handle laptop lid
  #   logind = {
  #     lidSwitch = "ignore";
  #     extraConfig = ''
  #       HandlePowerKey=ignore
  #     '';
  #   };
  #   acpid = {
  #     enable = true;
  #     lidEventCommands =
  #     ''
  #       export PATH=$PATH:/run/current-system/sw/bin

  #       lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
  #       if [ $lid_state = "closed" ]; then
  #         # Set brightness to zero
  #         echo 0  > /sys/class/backlight/acpi_video0/brightness
  #       else
  #         # Reset the brightness
  #         echo 50  > /sys/class/backlight/acpi_video0/brightness
  #       fi
  #     '';

  #     powerEventCommands =
  #     ''
  #       systemctl suspend
  #     '';
  #   };

    systemPackages = with pkgs; [
      acpi
      brightnessctl
      cpupower-gui
      light
      # powertop
    ];
  } else {};

  # services = if myOptions.power.mobile then {
  #   thermald.enable = true;
  #   # cpupower-gui.enable = true;
  #   power-profiles-daemon.enable = false;
 
  #   upower = {
  #     enable = true;
  #     percentageLow = 20;
  #     percentageCritical = 5;
  #     percentageAction = 3;
  #     criticalPowerAction = "PowerOff";
  #   };

  #   auto-cpufreq = {
  #     # balanced performance powersave
  #     enable = true;
  #     settings = {
  #       battery = {
  #         governor = "powersave";
  #         turbo = "auto";
  #       };
  #       charger = {
  #         governor = "performance";
  #         turbo = "auto";
  #       };
  #     };
  #   };
  # } else {};

  # boot = if myOptions.power.mobile then {
  #   kernelModules = ["acpi_call"];
  #   extraModulePackages = with config.boot.kernelPackages;
  #     [
  #       acpi_call
  #       cpupower
  #     ]
  #     ++ [pkgs.cpupower-gui];
  # } else {};
}