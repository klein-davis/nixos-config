{ config, pkgs, lib, myOptions, ... }: {

  environment.variables = {
    EDITOR = "code";
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    GSETTINGS_BACKEND = "keyfile";
    LIBSEAT_BACKEND = "seatd";
    WAYLAND_DISPLAY = "wayland-1";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.sessionVariables = lib.mkMerge [
    {
      # >NIXOS_OZONE_WL = "1"; # Helps with Electron/Chromium-based apps on Wayland
      QT_QPA_PLATFORMTHEME = "qt5ct";
    }

    # NVIDIA-specific environment variables, applied only if enable-nvidia-gpu is true
    (lib.mkIf myOptions.enable-nvidia-gpu {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    })

    # AMD-specific environment variables, applied only if enable-amd-gpu is true
    (lib.mkIf myOptions.enable-amd-gpu {
      LIBVA_DRIVER_NAME = "radeonsi";
    })
    
    (lib.mkIf myOptions.prefered-gpu.enable {
      MESA_DRM_RENDER_NODE = myOptions.prefered-gpu.path;
    })
  ];


  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
}