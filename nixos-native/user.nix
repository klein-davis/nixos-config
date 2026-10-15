{ pkgs, config, inputs, host, pkgsBundle, myOptions, split-monitor-workspaces, ... }: {
  
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs host pkgsBundle myOptions; };
    users.${myOptions.username} = {
      imports = [ ./../home-manager ];
      home.username = "${myOptions.username}";
      home.homeDirectory = "/home/${myOptions.username}";
      home.stateVersion = config.system.stateVersion;
      programs.home-manager.enable = true;
    };
  };

  programs.zsh.enable = true;

  boot.kernelModules = [ "cp210x" "ch341" ];

  programs.ydotool.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users.${myOptions.username} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "video" "seat" "dialout" "uinput" "input" "tty" "wireshark" "ydotool"]
      ++ (if myOptions.virtualization then ["libvirtd"] else []);
      packages = with pkgs; [];
      shell = pkgs.zsh;
      initialPassword = "${myOptions.default-passwd}";
    };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = myOptions.enable-auto-login;
    user = "${myOptions.username}";
  };

  nix.settings.allowed-users = [ "${myOptions.username}" ];
}
