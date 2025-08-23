{ ... }:
{
  home.sessionVariables = {
    EDITOR = "code";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    NIXOS_OZONE_WL = "1";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    _JAVA_AWT_WM_NONEREPARENTING = "1";
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    DISABLE_QT5_COMPAT = "0";
    GDK_BACKEND = "wayland";
    ANKI_WAYLAND = "1";
    DIRENV_LOG_FORMAT = "";
    #LIBSEAT_BACKEND = "logind";
    LIBSEAT_BACKEND = "seatd";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_DRM_NO_ATOMIC = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_QPA_PLATFORM = "xcb";
    QT_QPA_PLATFORM = "wayland";
    # QT_STYLE_OVERRIDE = "qt5ct";
    MOZ_ENABLE_WAYLAND = "1";
    #WLR_BACKEND = "vulkan";
    #WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland,x11";
    CLUTTER_BACKEND = "wayland";
    GTK_THEME = "Breeze-Dark";
  };

  xdg.mimeApps = {
    enable = true; # Enable XDG MIME applications management
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
      "x-scheme-handler/mailto" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";
      # Image viewing
      "image/jpeg" = "viewnior.desktop";
      "image/png" = "viewnior.desktop";
      "image/gif" = "viewnior.desktop";
      "image/bmp" = "viewnior.desktop";
      "image/tiff" = "viewnior.desktop";
      "image/webp" = "viewnior.desktop";
    };
  };
}
