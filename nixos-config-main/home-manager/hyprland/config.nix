{ myOptions, ... }: 
{
  wayland.windowManager.hyprland = {

    settings = {
      "$mainMod" = "SUPER";

      monitor = [
        # Rightmost monitor (1920x1080)
        #"DP-1, 1920x1080@60, 3840x92, 1"  # Landscape, Rightmost
        #"DP-1, 1920x1080@60, 1920x0, 1"  # Landscape, Rightmost

        # Center monitor
        #"DP-2, 1920x1200@60, 1920x0, 1"  # Landscape, Center

        # Leftmost monitor
        #"DP-3, 1920x1200@60, 0x0, 1"  # Landscape, Leftmost

        # Rightmost monitor (1920x1080)
        "DP-1, 1920x1200@60, 3840x0, 1"  # Landscape, Rightmost
        #"DP-1, 1920x1080@60, 1920x0, 1"  # Landscape, Rightmost

        # Center monitor
        "DP-3, 1920x1080@120, 1920x92, 1"  # Landscape, Center

        # Leftmost monitor
        "DP-2, 1920x1200@60, 0x0, 1"  # Landscape, Leftmost

      ]
      ++ [ ",preferred,auto,1" ];

      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XCURSOR_SIZE,36"
        "QT_QPA_PLATFORM,wayland"
        "XDG_SCREENSHOTS_DIR,~/screens"
      ];

      debug = {
        disable_logs = false;
        enable_stdout_logs = true;
      };

      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_options = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 3;
        #
        #/* CSV */
        # 050505,515151,b5b5b5,7c7c7c,3c3c3c,272727,848484,737474,343434,1c1c1c

        # /* Array */
        # ["050505","515151","b5b5b5","7c7c7c","3c3c3c","272727","848484","737474","343434","1c1c1c"]
        #
        "col.active_border" = "rgba(ffffffee) rgba(1c1c1cee) rgba(ffffffee) 45deg";
        "col.inactive_border" = "rgba(1c1c1cff)";

        layout = "dwindle";

        #no_cursor_warps = false;
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 2;
          passes = 2;
          new_optimizations = true;
        };

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;

        # bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        # bezier = "myBezier, 0.33, 0.82, 0.9, -0.08";
        bezier = "myBezier, 0.1, 0.9, 0.1, 1.1";

        animation = [
          "windows,     1, 7,  myBezier"
          "windowsOut,  1, 7,  default, popin 80%"
          "border,      1, 10, default"
          "borderangle, 1, 8,  default"
          "fade,        1, 7,  default"
          "workspaces,  1, 6,  default"
        ];
      };

      dwindle = {
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_invert = false;
        workspace_swipe_distance = 200;
        workspace_swipe_forever = true;
      };

      misc = {
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        enable_swallow = true;
        render_ahead_of_time = false;
        disable_hyprland_logo = true;
      };

      windowrule = [
        "float, ^(imv)$"
        "float, ^(mpv)$"
      ];

      # autostart
      exec-once = [
        "systemctl --user import-environment &"
        "hash dbus-update-activation-environment 2>/dev/null &"
        "dbus-update-activation-environment --systemd &"
        "nm-applet &"
        "wl-clip-persist --clipboard both"
        "swaybg -m fill -i $(find ~/Pictures/wallpapers/ -maxdepth 1 -type f) &"
        "sleep 1 && swaylock"
        "hyprctl setcursor Nordzy-cursors 22 &"
        "poweralertd &"
        "waybar &"
        "mako &"
        "wl-paste --watch cliphist store &"
      ] ++ (if myOptions.enable-rgb-lights then ["(sleep 6 && openrgb --startminimized) &"] else []);


      bind = [
        "$mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        "$mainMod, Return, exec, alacritty"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, nemo ~"
        "$mainMod, F, togglefloating,"
        "$mainMod, D, exec, wofi --show drun"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, J, togglesplit, # dwindle"
        "$mainMod, T, exec, kitty"
        "$mainMod, O, exec, systemctl suspend"

        # Move focus with mainMod + arrow keys
        "$mainMod, left,  movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up,    movefocus, u"
        "$mainMod, down,  movefocus, d"

        # Moving windows
        "$mainMod SHIFT, left,  swapwindow, l"
        "$mainMod SHIFT, right, swapwindow, r"
        "$mainMod SHIFT, up,    swapwindow, u"
        "$mainMod SHIFT, down,  swapwindow, d"

        # Window resizing                     X  Y
        "$mainMod CTRL, left,  resizeactive, -60 0"
        "$mainMod CTRL, right, resizeactive,  60 0"
        "$mainMod CTRL, up,    resizeactive,  0 -60"
        "$mainMod CTRL, down,  resizeactive,  0  60"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, split-workspace, 1"
        "$mainMod, 2, split-workspace, 2"
        "$mainMod, 3, split-workspace, 3"
        "$mainMod, 4, split-workspace, 4"
        "$mainMod, 5, split-workspace, 5"
        "$mainMod, 6, split-workspace, 6"
        "$mainMod, 7, split-workspace, 7"
        "$mainMod, 8, split-workspace, 8"
        "$mainMod, 9, split-workspace, 9"
        "$mainMod, 0, split-workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, split-movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, split-movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, split-movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, split-movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, split-movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, split-movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, split-movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, split-movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, split-movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, split-movetoworkspacesilent, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Keyboard backlight
        "$mainMod, F3, exec, brightnessctl -d *::kbd_backlight set +33%"
        "$mainMod, F2, exec, brightnessctl -d *::kbd_backlight set 33%-"

        # Volume and Media Control
        ", XF86AudioRaiseVolume, exec, pamixer -i 5 "
        ", XF86AudioLowerVolume, exec, pamixer -d 5 "
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -m"
        "$mainMod ALT, up, exec, pamixer -i 5"
        "$mainMod ALT, down, exec, pamixer -d 5"
        #"$mainMod, S, mouse_up, exec, pamixer -i 5"
        #"$mainMod, S, mouse_up, exec, pamixer -i 5"
        
        # Brightness control
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%- "
        ", XF86MonBrightnessUp, exec, brightnessctl set +5% "

        # Configuration files
        ''$mainMod SHIFT, N, exec, alacritty -e sh -c "rb"''
        ''$mainMod SHIFT, C, exec, alacritty -e sh -c "conf"''
        ''$mainMod SHIFT, H, exec, alacritty -e sh -c "code ~/nix/home-manager/modules/wms/hyprland.nix"''
        ''$mainMod SHIFT, W, exec, alacritty -e sh -c "code ~/nix/home-manager/modules/wms/waybar.nix''
        '', Print, exec, grim -g "$(slurp)" - | swappy -f -''

        # Waybar
        "$mainMod, B, exec, pkill -SIGUSR1 waybar"
        "$mainMod, W, exec, pkill -SIGUSR2 waybar"

        # Disable all effects
        "$mainMod Shift, G, exec, ~/.config/hypr/gamemode.sh "

        # Lock
        "$mainMod, L, exec, swaylock"

        # Screenshots
        #, print, exec, $HOME/.config/hypr/scripts/screenshots/captureAll.sh
        #CTRL, print, exec, $HOME/.config/hypr/scripts/screenshots/captureScreen.sh
        #CTRL SHIFT, print, exec, $HOME/.config/hypr/scripts/screenshots/captureArea.sh

        # Screenshots
        ", print, exec, grim $(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png')"
        "CTRL, print, exec, grim -g \"$(slurp -o)\" $(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png')"
        "CTRL SHIFT, print, exec, grim -g \"$(slurp)\" $(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png')"

      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
