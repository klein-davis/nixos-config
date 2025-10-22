{ config, pkgs, myOptions, lib, ... }:
rec {  
  environment.systemPackages = with pkgs; [
    libva-utils
    vdpauinfo
    vulkan-tools
  ];

  #Most wayland compositors need this
  hardware = {
    graphics = {
      enable = true;
      # Some options for amdgpu
      enable32Bit = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
        vaapiVdpau
        vpl-gpu-rt
      ]
      ++ (if myOptions.enable-amd-gpu then with pkgs; [ 
        # amdvlk
        rocmPackages.clr.icd
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ] else []);


      extraPackages32 = [] 
      ++ (if myOptions.enable-amd-gpu then with pkgs; [ 
        # driversi686Linux.amdvlk
      ] else []);


      # extraPackages32 = []
      # ++ (if myOptions.enable-amd-gpu then [pkgs.pkgsi686Linux.mesa.drivers.radeonsi pkgs.pkgsi686Linux.mesa.drivers.radeonsi] else []);
    };
    nvidia = if (myOptions.enable-nvidia-gpu) then {
      # open = true; # For stylix
      open = false;
      modesetting.enable = true;
      powerManagement.enable = true;
      # powerManagement.finegrained = true;
      # prime.offload.enable = true;
      nvidiaSettings = false;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = config.boot.kernelPackages.nvidiaPackages.beta;

      # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #   version = "555.58";
      #   sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
      #   sha256_aarch64 = "sha256-7XswQwW1iFP4ji5mbRQ6PVEhD4SGWpjUJe1o8zoXYRE=";
      #   openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
      #   settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
      #   persistencedSha256 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
      # };
    } else {};

    # Removed
    # amdgpu.amdvlk = if (myOptions.enable-amd-gpu) then {
    #   enable = true;
    #   support32Bit.enable = true;
    # } else {};
  };

  # Environment variables related to graphics
  environment.sessionVariables = lib.mkMerge [
    {
      # >NIXOS_OZONE_WL = "1"; # Helps with Electron/Chromium-based apps on Wayland
      # QT_QPA_PLATFORMTHEME = "qt5ct";
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
}
