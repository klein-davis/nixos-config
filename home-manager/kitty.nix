{ lib, ... }: 
{
  programs.kitty = {
    enable = true;

    settings = {
      confirm_os_window_close = 0;
      font_size = 8; # matches the old stylix fonts.sizes.terminal value
      background_opacity = lib.mkForce "0.4";
      background_blur = "1";
      window_padding_width = 10;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      mouse_hide_wait = 60;
      
      ## Tabs
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
    };

    # Pre-seed the include so Noctalia's kitty apply-hook (which rewrites
    # kitty.conf at runtime) sees its target state already present and
    # no-ops instead of trying to write through the Nix-store symlink.
    extraConfig = ''
      include themes/noctalia.conf
    '';

    keybindings = {
      ## Tabs
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";

      ## Unbind
      "ctrl+shift+left" = "no_op";
      "ctrl+shift+right" = "no_op";
    };
  };
}