{ self, pkgs, lib, inputs, myOptions, ...}: 
{
  # imports = [ inputs.nix-gaming.nixosModules.default ];
  boot.tmp.cleanOnBoot = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    #xorg.libXrender
  ];

  environment.sessionVariables = {
    #NIX_LD = lib.mkForce lib.mkIf (myOptions.system == "x86_64-linux") "${pkgs.glibc}/lib64/ld-linux-x86-64.so.2";
    #NIX_LD_LIBRARY_PATH = impureLibraryPath;
  };

  virtualisation.podman.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://nix-gaming.cachix.org" "https://nixpkgs-python.cachix.org" "https://devenv.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=" ];
    };
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
        trusted-users = root ${myOptions.username};
        '';
  };
  nixpkgs = {
    overlays = [
      #self.overlays.default
      #inputs.nur.overlay
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
