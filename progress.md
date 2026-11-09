# RustDesk bidirectional unattended access: progress

Machines: desktop `DESKTOP-GV1U8SC` (flake host `desktop`, hosts hbbs/hbbr at 100.111.87.46) and Framework 1 laptop `LAPTOP-PDQ3S7` (flake host `framework1`, 100.73.210.27).

## Goal
RustDesk works laptop to desktop and desktop to laptop over Tailscale, fully unattended, with no screen picker.

## Done and tested
- Laptop to desktop and desktop to laptop both connect through the GUI (Discovered tab, double-click) with the saved password. No picker and no approval click. Mouse and keyboard control inside a session is untested.
- `nixos-native/packages/rustdesk-client.nix` (new):
  - `rustdesk-server` user service (`rustdesk --server`), restarted together with Luminous
  - `rustdesk-tailnet-discovery` service: pings tailnet peers on UDP 21119 and merges replies into `RustDesk_lan_peers.toml`, so peers show in the Discovered tab
  - firewall rules on `tailscale0`
- `nixos-native/packages/default.nix`: rustdesk wrapper moved into the new file.
- `nixos-native/display.nix`: removed duplicate `xdg-desktop-portal-hyprland` from `extraPortals` (it broke the `user-units` build).
- `nixos-native/packages/deskflow.nix` and `patches/xdg-desktop-portal-luminous/luminous-all-outputs.patch`: with `LUMINOUS_ALL_OUTPUTS=1` (desktop) Luminous skips the output picker and returns one PipeWire stream per output, each with position and size. Replaces the earlier single-output `LUMINOUS_DEFAULT_OUTPUT` patch. RustDesk now lists all 3 monitors (DP-3, DP-2, DP-1), tested from the laptop: each shows a different screen.
- Per-machine config (not in repo): `allow-hide-cm`, permanent password, and on the laptop `approve-mode` and `verification-method` options in `~/.config/rustdesk/`. Backups are saved as `*.pre-unattended`.

## Latest: "x11 error" on first connect, fine on retry
- Cause: when a monitor wakes from DPMS, Hyprland recreates its output. Luminous's long-lived cast still points at the old one. The next connection triggers a Wayland protocol error and Luminous aborts (`pipewirethread.rs:220`). systemd restarts it, so the retry works.
- Fix: new `luminous-refresh-on-monitor-add` user service in `rustdesk-client.nix`. It listens on Hyprland's event socket and restarts Luminous (and RustDesk with it) on `monitoraddedv2`, at most once per 10 s.
- Both hosts build on the laptop. Not yet switched or tested live.

## To do
- Run `sudo nixos-rebuild switch --flake .#desktop` and `.#framework1`. The new service starts at the next Hyprland login, or with `systemctl --user start luminous-refresh-on-monitor-add`.
- Test: let the desktop's screens sleep, then connect from the laptop. The first connect should work.
- Test mouse and keyboard control in a session, and test after a reboot.
- Replace the permanent password with one you choose.
- Desktop lock screen: an unattended connection lands on the lock screen (idle lock is 360 s).
- Luminous itself still aborts on a stale output; the restart service works around it rather than fixing it.
- Nothing is committed. Your own uncommitted `flake.nix`, `home-manager/hyprland/config.nix` and `nixos-native/services.nix` are untouched and should stay out of the commit.

## Screens and input (2026-10-29)
- Desktop is running the patched Luminous through a runtime drop-in `/run/user/1000/systemd/user/xdg-desktop-portal-luminous.service.d/test.conf`. It vanishes at reboot; `nixos-rebuild switch --flake .#desktop` makes it permanent.
- (Fixed in config, needs `switch`: new root `rustdesk` system service; user `rustdesk-server` unit replaced by `rustdesk-restart-with-luminous`.) Remote mouse and keyboard did not work before it. RustDesk 1.5.0's `--server` on Wayland sends input to a root `rustdesk --service` process (uinput over IPC), and nothing runs it (`Failed to update mouse resolution: No such file or directory`). Needs a NixOS system service; untested because it needs sudo on the desktop.
- `notify_pointer_motion_absolute` now adds the stream's position. Untested, since RustDesk's server never calls it.
- Seen once more: "Buffer allocation failed" (PipeWire, also on Oct 28) and the "x11 expected" retry error right after restarting the services.

## Round 2 (2026-10-30)
- After the root `rustdesk` service existed, RustDesk captures through the plain ScreenCast portal (not RemoteDesktop) and uses uinput for input. The all-outputs patch now covers `screencast.rs` too (it showed the "Share Your Screen" picker before).
- The service spawns the server via `sudo-rs -u nixuser -- env ...`, which dropped `GST_PLUGIN_SYSTEM_PATH_1_0` ("could not load pipewiresrc"). Fixed with `Defaults:root env_keep` in `security.sudo-rs.extraConfig` (rustdesk-client.nix). Needs a switch on each host.
- Runtime drop-in on the desktop (`/run/user/1000/systemd/user/xdg-desktop-portal-luminous.service.d/test.conf`) pins the new Luminous until the switch; remove it afterwards.

## Test results (2026-10-30, after both switches)
- Verified from the laptop: root `rustdesk` service runs; server spawned by it; ScreenCast starts 3 streams with no picker and no pipewiresrc error; display selector shows 3 monitors (1 = DP-3 left, 2 = DP-1 right, 3 = DP-2 middle); mouse moves and clicks land on the right monitor (checked ~4 points, within a few px) and the left button reaches the `mouce-library-fake-mouse` evdev device.
- NOT working / unresolved: keyboard from the viewer. Synthetic keys (ydotool `q`, wtype `q`, shift, ctrl) reach the viewer's own ID field but never appear on the desktop's `RustDesk UInput Keyboard` evdev node, in map, translate and legacy modes. Forcing `RUSTDESK_FORCED_DISPLAY_SERVER=wayland` on the laptop did not change it. The laptop's login session is `Type=tty` (the desktop's is `wayland`), which may confuse RustDesk's X11/Wayland detection. A real keyboard has not been tried.
- Viewer keyboard mode on the laptop was left on Legacy (was Map).
