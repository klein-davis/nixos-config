{ pkgs, inputs, host, pkgsBundle, myOptions, split-monitor-workspaces, ... }: {
  
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
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
  };

  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users.${myOptions.username} = {
      isNormalUser = true;
      description = "My Silly Name Here";
      extraGroups = [ "networkmanager" "wheel" "video" "seat" "vboxusers"]
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
