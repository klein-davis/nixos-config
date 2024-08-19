{ pkgs, config, myOptions, ... }: {

  # mobile = false
  powerManagement.cpuFreqGovernor = if ! myOptions.power.mobile then ("performance") else ();
  
  # mobile = true
  environment = if myOptions.power.mobile then {
    systemPackages = with pkgs; [
      acpi
      brightnessctl
      cpupower-gui
      light
      powertop
    ];
  } else {};

  services = if myOptions.power.mobile then {
    # thermald.enable = true;
    # cpupower-gui.enable = true;
    power-profiles-daemon.enable = false;
 
    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    auto-cpufreq = {
      # balanced performance powersave
      enable = true;
      settings = {
        battery = {
          governor = "balanced";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  } else {};

  boot = if myOptions.power.mobile then {
    kernelModules = ["acpi_call"];
    extraModulePackages = with config.boot.kernelPackages;
      [
        acpi_call
        cpupower
      ]
      ++ [pkgs.cpupower-gui];
  } else {};
}