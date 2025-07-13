{ config, pkgs, lib, myOptions, ... }: {

  environment.variables = {
    EDITOR = "code";
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    #QT_QPA_PLATFORMTHEME = "qt5ct";
    GSETTINGS_BACKEND = "keyfile";
    LIBSEAT_BACKEND = "seatd";
    WAYLAND_DISPLAY = "wayland-1";
    # XDG_USER_DIR = "/home/${myOptions.username}";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Hyperland Nvidia configuration
  #environment.sessionVariables = {
    # Hint electron apps to use wayland
    #NIXOS_OZONE_WL = "1";
  #};
  # Conditional Environment Variables for GPU and Wayland
  # This section sets environment variables based on the enabled GPU type.
  environment.sessionVariables = lib.mkMerge [
    # Variables that should always be set (e.g., for general Wayland compatibility)
    {
      NIXOS_OZONE_WL = "1"; # Helps with Electron/Chromium-based apps on Wayland
    }

    # NVIDIA-specific environment variables, applied only if enable-nvidia-gpu is true
    (lib.mkIf myOptions.enable-nvidia-gpu {
      LIBVA_DRIVER_NAME = "nvidia"; # Tells libva to use NVIDIA's VA-API driver
      GBM_BACKEND = "nvidia-drm";   # Specifies NVIDIA's Generic Buffer Management backend
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Directs GLX to use NVIDIA's implementation
    })

    # AMD-specific environment variables, applied only if enable-amd-gpu is true
    (lib.mkIf myOptions.enable-amd-gpu {
      LIBVA_DRIVER_NAME = "radeonsi"; # Tells libva to use the Mesa 'radeonsi' driver for AMD
      # For AMD, 'GBM_BACKEND' and '__GLX_VENDOR_LIBRARY_NAME' are typically
      # handled implicitly by the 'amdgpu' kernel module and 'mesa' userspace drivers.
      # Explicitly setting them might be redundant or even cause issues if not
      # precisely correct for all AMD setups. It's generally best to let the
      # system auto-configure these for AMD unless you have a specific reason to force them.
      # If you *were* to set them, they would typically be:
      # GBM_BACKEND = "amdgpu";
      # __GLX_VENDOR_LIBRARY_NAME = "mesa";
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