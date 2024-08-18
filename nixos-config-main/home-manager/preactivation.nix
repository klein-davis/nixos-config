{
home.activation.preActivation = ''
    # Ensure ~/.config/gtk-4.0/settings.ini config file is removed before activation
    if [ -f "${config.xdg.configHome}/gtk-4.0/settings.ini" ]; then
      rm -f "${config.xdg.configHome}/gtk-4.0/settings.ini"
    fi
    
    # Ensure ~/.config/gtk-4.0/gtk.css config file is removed before activation
    if [ -f "${config.xdg.configHome}/gtk-4.0/gtk.css" ]; then
      rm -f "${config.xdg.configHome}/gtk-4.0/gtk.css"
    fi

    # Ensure ~/.config/gtk-3.0/settings.ini config file is removed before activation
    if [ -f "${config.xdg.configHome}/gtk-3.0/settings.ini" ]; then
      rm -f "${config.xdg.configHome}/gtk-3.0/settings.ini"
    fi

    # Ensure ~/.config/gtkrc-2.0 config file is removed before activation
    if [ -f "${config.xdg.configHome}/gtkrc-2.0" ]; then
      rm -f "${config.xdg.configHome}/gtkrc-2.0"
    fi
  '';
}