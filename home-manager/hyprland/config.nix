{ inputs, config, lib, myOptions, pkgs, ... }:
let
  mkLua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };

  # A plain `exec` bind: hl.bind(key, hl.dsp.exec_cmd(cmd))
  execBind = key: cmd: { _args = [ key (mkLua "hl.dsp.exec_cmd(${toLua cmd})") ]; };
  # A plain `exec` bind with opts (bindl/bindm-style flags).
  execBindOpts = key: cmd: opts: { _args = [ key (mkLua "hl.dsp.exec_cmd(${toLua cmd})") opts ]; };
  # A bind whose action is an arbitrary hl.dsp.* expression (raw lua source).
  dispBind = key: dispExpr: { _args = [ key (mkLua dispExpr) ]; };
  dispBindOpts = key: dispExpr: opts: { _args = [ key (mkLua dispExpr) opts ]; };

  # Parse the legacy hyprlang monitor rule string ("name, mode, position, scale")
  # used by myOptions.screens into the table shape hl.monitor() expects.
  parseMonitor = s:
    let parts = lib.splitString ", " s;
    in {
      output = builtins.elemAt parts 0;
      mode = builtins.elemAt parts 1;
      position = builtins.elemAt parts 2;
      scale = builtins.elemAt parts 3;
    };

  # Parse the legacy hyprlang "NAME,value" env string into hl.env(name, value) args.
  parseEnv = s: { _args = lib.splitString "," s; };

  brightnessScript = pkgs.writeShellApplication {
    name = "hypr-brightness";
    runtimeInputs = [ pkgs.brightnessctl pkgs.socat ];
    text = builtins.readFile ../scripts/hypr_brightness.sh;
  };

  dpmsWakeScript = import ../scripts/hypr-dpms-wake.nix { inherit pkgs; };

  fixLowResScript = pkgs.writeShellApplication {
    name = "hypr-fix-low-res";
    runtimeInputs = [ pkgs.jq ];
    # Drop the source file's own shebang line so it doesn't end up stranded
    # mid-script after writeShellApplication's own header + our export line.
    text = ''
      export HYPR_CONFIGURED_MONITORS_JSON=${lib.escapeShellArg (builtins.toJSON (map parseMonitor myOptions.screens))}
    '' + lib.concatStringsSep "\n" (lib.tail (lib.splitString "\n" (builtins.readFile ../scripts/hypr_fix_low_res.sh)));
  };

  workspaceNumbers = lib.range 1 10;
  workspaceKey = i: if i == 10 then "0" else toString i;

  # `content` on extraLuaFiles wants either a real Nix `path` value (copies
  # the file) or the literal text (written verbatim). String-interpolating
  # a flake input produces a string, which the option treats as literal
  # text rather than a path to copy - so read the file ourselves instead.
  smwLua = name: builtins.readFile "${inputs.split-monitor-workspaces}/lua/${name}.lua";
in
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = map parseMonitor myOptions.screens ++ [
        { output = ""; mode = "preferred"; position = "auto"; scale = "1"; }
      ];

      env = map parseEnv [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XCURSOR_SIZE,36"
        # "QT_QPA_PLATFORM,wayland"
        "XDG_SCREENSHOTS_DIR,~/Pictures/Screenshots"
      ];

      # split-monitor-workspaces ships a pure-Lua library for the new Lua
      # config (no more .so plugin / hl.plugin.load) - see the files staged
      # via extraLuaFiles below. Requiring it here (as a `_var`) makes the
      # `smw` local available both to the bind list below and to
      # extraConfig, since the whole generated file is one Lua chunk.
      smw = { _var = mkLua ''require("smw.split-monitor-workspaces")''; };

      config = {
        debug = {
          disable_logs = false;
          enable_stdout_logs = true;
          # For fractional scaling
          disable_scale_checks = true;
        };

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_options = "";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
          };

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        general = {
          gaps_in = 5;
          gaps_out = 18;
          border_size = 3;

          # col.active_border / col.inactive_border are set at the bottom of
          # extraConfig, after Noctalia's colors (~/.config/hypr/noctalia.conf)
          # are parsed - they use Noctalia's primary/secondary/surface colors,
          # which are only known at runtime and can change without a rebuild.

          layout = "dwindle";
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;
            size = 2;
            passes = 2;
            new_optimizations = true;
          };
        };

        animations = {
          enabled = true;
        };

        dwindle = {
          # pseudotile is bound to mainMod + P below
          preserve_split = true; # you probably want this
        };

        master = {
          new_status = "master";
        };

        misc = {
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          enable_swallow = true;
          disable_hyprland_logo = true;
          enable_anr_dialog = false;
        };
      };

      curve = {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [ [ 0.1 0.9 ] [ 0.1 1.1 ] ];
          }
        ];
      };

      animation = [
        { leaf = "windows"; enabled = true; speed = 7; bezier = "myBezier"; }
        { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 80%"; }
        { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "borderangle"; enabled = true; speed = 8; bezier = "default"; }
        { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; }
        { leaf = "workspaces"; enabled = true; speed = 6; bezier = "default"; }
      ];

      # autostart - equivalent of hyprlang's exec-once, run once the
      # compositor has finished starting (systemd activation is handled
      # separately by the module itself via systemd.enable below).
      on = {
        _args = [
          "hyprland.start"
          (mkLua (
            "function()\n"
            + lib.concatMapStrings (cmd: "  hl.exec_cmd(${toLua cmd})\n") (
              [
                "systemctl --user import-environment &"
                "hash dbus-update-activation-environment 2>/dev/null &"
                "dbus-update-activation-environment --systemd &"
                "nm-applet &"
                "hyprsunset --identity &"
                "noctalia &"
                "poweralertd &"
                "wl-paste -t text --watch cliphist store &"
                "wl-paste -p -t text --watch cliphist store &"
                "wl-paste -p --watch xclip -i -selection primary &"
              ]
              ++ lib.optional myOptions.enable-rgb-lights "(sleep 6 && openrgb --startminimized) &"
            )
            + "end"
          ))
        ];
      };

      bind =
        [
          (execBind "SUPER + V" "noctalia msg panel-toggle clipboard")

          (execBind "SUPER + Return" "kitty")
          (dispBind "SUPER + Q" "hl.dsp.window.close()")
          (execBind "SUPER + A" "hyprctl reload")
          (execBind "SUPER + R" "obsidian")
          (execBind "SUPER + C" "codium")
          (execBind "SUPER + E" "nemo ~")
          (execBind "SUPER + H" "hyprpicker -a") # pick a color, copy to clipboard
          (dispBind "SUPER + G" "hl.dsp.window.float()")
          (dispBind "SUPER + F" "hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = \"toggle\" })")
          (execBind "SUPER + D" "noctalia msg panel-toggle launcher")
          (dispBind "SUPER + SHIFT + P" "hl.dsp.window.pseudo()") # dwindle
          (dispBind "SUPER + P" "hl.dsp.window.pin()")
          (execBind "SUPER + T" "kitty")
          (execBind "SUPER + L" "noctalia msg session lock")
          (execBind "SUPER + S" "firefox")

          # Cycle through windows
          (dispBind "ALT + Tab" "hl.dsp.window.bring_to_top()")
          (dispBind "ALT + Tab" "hl.dsp.window.cycle_next()")
          (dispBind "ALT + SHIFT + Tab" "hl.dsp.window.cycle_next({ next = false })")

          # Move focus with mainMod + arrow keys
          (dispBind "SUPER + left" "hl.dsp.focus({ direction = \"left\" })")
          (dispBind "SUPER + right" "hl.dsp.focus({ direction = \"right\" })")
          (dispBind "SUPER + up" "hl.dsp.focus({ direction = \"up\" })")
          (dispBind "SUPER + down" "hl.dsp.focus({ direction = \"down\" })")

          # Moving windows
          (dispBind "SUPER + SHIFT + left" "hl.dsp.window.swap({ direction = \"left\" })")
          (dispBind "SUPER + SHIFT + right" "hl.dsp.window.swap({ direction = \"right\" })")
          (dispBind "SUPER + SHIFT + up" "hl.dsp.window.swap({ direction = \"up\" })")
          (dispBind "SUPER + SHIFT + down" "hl.dsp.window.swap({ direction = \"down\" })")

          # Audio clip hotkeys
          (execBind "SUPER + ALT + 1" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "1*") --no-video'')
          (execBind "SUPER + ALT + 2" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "2*") --no-video'')
          (execBind "SUPER + ALT + 3" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "3*") --no-video'')
          (execBind "SUPER + ALT + 4" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "4*") --no-video'')
          (execBind "SUPER + ALT + 5" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "5*") --no-video'')
          (execBind "SUPER + ALT + 6" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "6*") --no-video'')
          (execBind "SUPER + ALT + 7" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "7*") --no-video'')
          (execBind "SUPER + ALT + 8" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "8*") --no-video'')
          (execBind "SUPER + ALT + 9" ''mpv $(find ~/Music/clips -maxdepth 1 -type f -name "9*") --no-video'')
          (execBind "SUPER + ALT + 0" "pkill mpv")

          # Window resizing                                    X    Y
          (dispBind "SUPER + CTRL + left" "hl.dsp.window.resize({ x = -60, y = 0, relative = true })")
          (dispBind "SUPER + CTRL + right" "hl.dsp.window.resize({ x = 60, y = 0, relative = true })")
          (dispBind "SUPER + CTRL + up" "hl.dsp.window.resize({ x = 0, y = -60, relative = true })")
          (dispBind "SUPER + CTRL + down" "hl.dsp.window.resize({ x = 0, y = 60, relative = true })")
        ]
        # Switch workspaces with mainMod + [0-9] (split-monitor-workspaces)
        ++ (map
          (i: dispBind "SUPER + ${workspaceKey i}" "smw.workspace(${toLua (toString i)})")
          workspaceNumbers)
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        ++ (map
          (i: dispBind "SUPER + SHIFT + ${workspaceKey i}" "smw.move_to_workspace_silent(${toLua (toString i)})")
          workspaceNumbers)
        ++ [
          # Scroll through existing workspaces with mainMod + side buttons
          (dispBind "SUPER + mouse:276" "hl.dsp.focus({ workspace = \"e+1\" })")
          (dispBind "SUPER + mouse:275" "hl.dsp.focus({ workspace = \"e-1\" })")

          # Keyboard backlight
          (execBind "SUPER + F3" "brightnessctl -d *::kbd_backlight set +33%")
          (execBind "SUPER + F2" "brightnessctl -d *::kbd_backlight set 33%-")

          # Volume and Media Control
          (execBind "XF86AudioRaiseVolume" "pamixer -i 5 ")
          (execBind "XF86AudioLowerVolume" "pamixer -d 5 ")
          (execBind "XF86AudioMute" "pamixer -t")
          (execBind "XF86AudioMicMute" "pamixer --default-source --toggle-mute")
          (execBind "XF86AudioPlay" "playerctl --all-players play-pause")
          (execBind "XF86AudioPause" "playerctl --all-players play-pause")
          (execBind "XF86AudioNext" "playerctl next")
          (execBind "XF86AudioPrev" "playerctl previous")
          (execBind "SUPER + ALT + right" "pamixer -t")
          (execBind "SUPER + ALT + up" "pamixer -i 5")
          (execBind "SUPER + ALT + down" "pamixer -d 5")
          (execBind "SUPER + ALT + left" "playerctl --all-players play-pause")
          (execBind "SUPER + ALT + m" "pamixer --default-source --toggle-mute")
          (execBind "SUPER + ALT + CTRL + right" "playerctl next")
          (execBind "SUPER + ALT + CTRL + left" "playerctl previous")

          # Brightness control - once brightnessctl bottoms out at 0% the
          # panel is still visibly lit, so extra presses dim further via
          # hyprsunset's gamma control (see ../scripts/hypr_brightness.sh).
          (execBind "XF86MonBrightnessDown" "${brightnessScript}/bin/hypr-brightness down")
          (execBind "XF86MonBrightnessUp" "${brightnessScript}/bin/hypr-brightness up")

          # Noctalia recovery - not run as a systemd service, so if it
          # crashes or hangs it needs a manual kick to come back.
          (execBind "SUPER + B" "pkill -x noctalia; sleep 0.3; noctalia &") # graceful restart
          (execBind "SUPER + W" "pkill -9 -x noctalia; sleep 0.3; noctalia &") # force restart if hung

          # Disable all effects
          (execBind "SUPER + SHIFT + G" "~/.config/hypr/gamemode.sh ")

          # Screenshots
          (execBind "Print" ''grim -g "$(slurp)" - | swappy -f -'')
          (execBind "CTRL + Print" ''grim -g "$(slurp)" - | wl-copy'')
          (execBind "SHIFT + Print" ''grim -g "$(slurp)" - $(find $HOME -name Pictures -maxdepth 1)/Screenshots/$(date +'%s_grim.png')'')
          (execBind "SUPER + CTRL + C" ''grim "/home/nixuser/Pictures/Cheat/$(date +'%Y-%m-%d_%H-%M-%S_full.png')"'')
          (execBind "SUPER + SHIFT + C" ''LATEST_FILE=$(ls -1 /home/nixuser/tmp/laptop/Pictures/Cheat/*.png 2>/dev/null | tail -n 1) && cat "$LATEST_FILE" | wl-copy --type "$(file -b --mime-type "$LATEST_FILE")"'')
          (execBind "SUPER + SHIFT + CTRL + C" ''(mkdir -p /home/nixuser/Pictures/Cheat && while true; do grim "/home/nixuser/Pictures/Cheat/$(date +'%Y-%m-%d_%H-%M-%S_full.png')"; sleep 30; done) &'')
          (execBind "SUPER + SHIFT + T" "pkill -f 'grim /home/nixuser/Pictures/Cheat'")

          (dispBind "SUPER + SHIFT + V" ''hl.dsp.submap("vnc")'')

          # Move/resize windows with mainMod + LMB/RMB and dragging
          (dispBindOpts "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
          (dispBindOpts "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

          # Screen and sleep hotkeys
          (execBindOpts "SUPER + SHIFT + CTRL + O" "noctalia msg session lock-and-suspend" { locked = true; })
          (execBindOpts "SUPER + Z" "${dpmsWakeScript}/bin/hypr-dpms-wake toggle superz" { locked = true; })
          (execBindOpts "SUPER + ALT + Z" "${fixLowResScript}/bin/hypr-fix-low-res" { locked = true; })
          (execBindOpts "SUPER + SHIFT + Z" "openrgb --mode off" { locked = true; })
        ];
    };

    extraLuaFiles = {
      "smw.globals" = { content = smwLua "globals"; autoLoad = false; };
      "smw.helpers" = { content = smwLua "helpers"; autoLoad = false; };
      "smw.monitors" = { content = smwLua "monitors"; autoLoad = false; };
      "smw.dispatchers" = { content = smwLua "dispatchers"; autoLoad = false; };
      "smw.split-monitor-workspaces" = { content = smwLua "split-monitor-workspaces"; autoLoad = false; };
    };

    # Custom Lua that can't be expressed as static `settings` data:
    #  - split-monitor-workspaces needs a setup() call (a statement, not a
    #    value/hl.<name>() call)
    #  - Noctalia's colors (~/.config/hypr/noctalia.conf) are regenerated at
    #    runtime whenever the user changes theme, and need to be re-read on
    #    every config reload - there's no Lua equivalent of hyprlang's
    #    `source = file.conf`, so we parse its `$name = value` lines
    #    ourselves and feed them into hl.config()/general.col + group
    #    colors, replicating what noctalia.conf itself used to set via
    #    `source`, plus our own active_border gradient override.
    #  - The "vnc" submap, where only Super+Shift+V (submap reset) works.
    #  - monitor_priority pins each monitor's workspace-range priority to its
    #    name (in myOptions.screens' left-to-right order) instead of letting
    #    split-monitor-workspaces auto-assign by connection order. Without
    #    this, a monitor that gets disabled/re-enabled (DPMS wake, our
    #    hypr-fix-low-res script, or the GPU/monitor itself dropping and
    #    re-establishing the link) gets a new internal monitor ID, which can
    #    permanently shuffle the auto-assigned order - so workspaces 11-20
    #    end up on the wrong physical screen even after `hyprctl reload`,
    #    since reload only re-derives priority from that same shuffled
    #    order rather than resetting it.
    extraConfig = ''
      smw.setup({
        workspace_count = 10,
        monitor_priority = ${toLua (map (m: m.output) (map parseMonitor myOptions.screens))},
      })

      local function load_noctalia_colors()
        local colors = {}
        local path = os.getenv("HOME") .. "/.config/hypr/noctalia.conf"
        local f = io.open(path, "r")
        if f then
          for line in f:lines() do
            local name, value = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
            if name then
              colors[name] = value
            end
          end
          f:close()
        end
        return colors
      end

      local noctalia = load_noctalia_colors()

      if noctalia.primary and noctalia.secondary and noctalia.surface then
        hl.config({
          general = {
            col = {
              active_border = { colors = { noctalia.primary, noctalia.secondary }, angle = 45 },
              inactive_border = noctalia.surface,
            },
          },
          group = {
            col = {
              border_active = noctalia.secondary,
              border_inactive = noctalia.surface,
              border_locked_active = noctalia.error,
              border_locked_inactive = noctalia.surface,
            },
            groupbar = {
              col = {
                active = noctalia.secondary,
                inactive = noctalia.surface,
                locked_active = noctalia.error,
                locked_inactive = noctalia.surface,
              },
            },
          },
        })
      end

      -- Only this keybind works while in the VNC submap.
      -- Press Super+Shift+V again to exit the submap.
      hl.define_submap("vnc", function()
        hl.bind("SUPER + SHIFT + V", hl.dsp.submap("reset"))
      end)

      -- sync_fullscreen defaults to true, which forces our internal
      -- (screen-covering) fullscreen mode to mirror whatever a client asks
      -- for on its own (e.g. Firefox's F11). Disabling it lets apps hide
      -- their own chrome via their normal fullscreen request without also
      -- growing the Hyprland-managed window to cover the whole monitor -
      -- matching the SUPER+F behavior above, which already keeps those two
      -- independent in the other direction.
      hl.window_rule({
        name = "decouple-client-fullscreen-from-window-size",
        match = { class = ".*" },
        sync_fullscreen = false,
      })
    '';
  };
}
