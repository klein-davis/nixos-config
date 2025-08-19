# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./samba.nix
    ];


  fileSystems."/share/main/Read-Only/Audio" = { 
    device = "/share/main/Audio";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/share/main/Read-Only/ROMs" = { 
    device = "/share/main/ROMs";
    fsType = "none";
    options = [ "bind" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "backupbeast"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.groups.smbgroup = {};
  users.groups.filegroup = {};

  users.users.backupbeast = {
    isNormalUser = true;
    description = "Backup Beast";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      
    ];
  };

  users.users.kleindavis = {
    isSystemUser = true;
    description = "Fileshare User";
    group = "filegroup";
    packages = with pkgs; [
      
    ];
  };


  users.users.smbuser = {
    isSystemUser = true; # To make use with no login
    description = "Null User for SMB";
    group = "smbgroup";
    packages = with pkgs; [

    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "backupbeast";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes Support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
    kate
    git
    steam
    vscode
    gparted
    fzf
    btop
    fastfetch
    unzip
    ffmpeg
    zip
    pipewire
    pulseaudio
    pamixer
    rustdesk
    opera
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?


  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = optigroup
      server string = Nixos Optiplex NAS
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      #hosts allow = 192.168.0. 127.0.0.1 localhost
      #hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      name resolve order = bcast host
    '';
    shares = {
      "Public" = {
        path = "/share/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "smbuser";
        "force group" = "smbgroup";
      };
      "Main" = {
        path = "/share/main";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "smbuser";
        "force group" = "smbgroup";
      };
      "Read-Only" = {
        path = "/share/main/Read-Only";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "smbuser";
        "force group" = "smbgroup";
      };
    };
};

services.samba-wsdd = {
 enable = true;
 openFirewall = true;
};

networking.firewall.enable = true;
networking.firewall.allowPing = true;
}
