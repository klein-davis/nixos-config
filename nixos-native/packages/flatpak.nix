{ inputs, config, ... } : {

  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    update = {
      auto = {
        enable = true;
        onCalendar = "weekly";
        
      };
      onActivation = true;
    };
    packages = [
      # { appId = "com.brave.Browser"; origin = "flathub";  }
      "com.obsproject.Studio"
      # "im.riot.Riot"
      { appId = "com.bambulab.BambuStudio"; origin = "flathub";  }
      "org.vinegarhq.Sober"
      "com.github.tchx84.Flatseal"
      "com.usebottles.bottles"
    ];
  };

  # FIXME: DEPMOD=true stops modules_install from writing modules.* index files that
  # collide with the kernel's. Drop once nixpkgs#575861 reaches nixos-unstable.
  boot.extraModulePackages = with config.boot.kernelPackages; [
    (v4l2loopback.overrideAttrs (o: { installFlags = (o.installFlags or [ ]) ++ [ "DEPMOD=true" ]; }))
  ];

}