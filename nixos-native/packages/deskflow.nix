{ pkgs, lib, inputs, host, myOptions, ... }:
let
  # Wayland clipboard sync needs Deskflow master (deskflow#9431, not in a release
  # yet), libportal >= 0.10 and a portal backend with Clipboard/RemoteDesktop/
  # InputCapture. See deskflow#9600. Drop these overrides once nixpkgs catches up.
  libportal = pkgs.libportal.overrideAttrs (_: rec {
    version = "0.11.0";
    src = pkgs.fetchFromGitHub {
      owner = "flatpak"; repo = "libportal"; rev = version;
      hash = "sha256-9p1YniRgPxHGaV8hRwIyYaIrXDcXboq3kKHZ6xrJn70=";
    };
    patches = [ ];
  });

  deskflow = (pkgs.deskflow.override { inherit libportal; }).overrideAttrs (o: {
    # xdg-desktop-portal-hyprland only offers InputCapture v1, which can't carry the
    # clipboard, so the server never requests it. This opens a device-less
    # RemoteDesktop session (served by Luminous) for clipboard access instead.
    patches = (o.patches or [ ]) ++ [ ../../patches/deskflow/deskflow-server-rd-clipboard.patch ../../patches/deskflow/deskflow-server-serve-while-active.patch ../../patches/deskflow/deskflow-server-claim-on-remote-copy.patch ];
    version = "1.27.0.1-unstable-2026-10-16";
    src = pkgs.fetchFromGitHub {
      owner = "deskflow"; repo = "deskflow";
      rev = "52f92f784c8ef00fc7865a4797a2c48afdadedd0";
      hash = "sha256-KrbX0i6/HGjoTtlxqNcXyj4100IazwWHC1TmnUrfqeA=";
    };
    doCheck = false;
  });

  # Release 0.1.21 predates its Clipboard/InputCapture/EIS fixes.
  luminous = pkgs.xdg-desktop-portal-luminous.overrideAttrs (o: rec {
    version = "0.1.21-unstable-2026-10";
    # RemoteDesktop.Start holds the SESSIONS lock while ensure_clipboard_session
    # locks it again, so Start never returns once a client requests the clipboard.
    patches = (o.patches or [ ]) ++ [ ../../patches/xdg-desktop-portal-luminous/luminous-remote-start-deadlock.patch ../../patches/xdg-desktop-portal-luminous/luminous-eis-region.patch ];
    src = pkgs.fetchFromGitHub {
      owner = "waycrate"; repo = "xdg-desktop-portal-luminous";
      rev = "9ca09f5f";
      hash = "sha256-OIpnu5R5PhxuHGtL/YEPN4pyJsrhrT5VzhJ1WkGJjsI=";
    };
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src version;
      pname = o.pname;
      hash = "sha256-3+h7QqrAz8u4MMycQWJ8ioFSjvzAomEFZBhDSj9xjwU=";
    };
  });

  systemctl = "${pkgs.systemd}/bin/systemctl";

  # Desktop is the server, framework1 the client. Settings (screen names, TLS,
  # layout) stay GUI-managed in ~/.config/Deskflow; services run deskflow-core
  # headless so there are no windows or error dialogs.
  isServer = host == "desktop";
  isClient = host == "framework1";

  # MAC of the default gateway on the desk's wired LAN (10.31.0.1).
  deskGatewayMac = "00:10:db:ff:10:01";

  # Exit 0 when the laptop is at the desk: on AC and on wired ethernet whose
  # gateway is the desk router (so ethernet elsewhere doesn't count).
  atDesk = pkgs.writeShellScriptBin "deskflow-at-desk" ''
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gawk pkgs.iproute2 ]}:$PATH

    ac=0
    for ps in /sys/class/power_supply/*; do
      if [ "$(cat "$ps/type" 2>/dev/null)" = Mains ] && [ "$(cat "$ps/online" 2>/dev/null)" = 1 ]; then
        ac=1
      fi
    done
    [ "$ac" = 1 ] || exit 1

    gatewayMac() {
      ip neigh show "$1" dev "$2" | awk '{ for (i = 1; i < NF; i++) if ($i == "lladdr") print tolower($(i + 1)) }'
    }

    while read -r gw dev; do
      [ -n "$gw" ] && [ -n "$dev" ] || continue
      # Physical wired NICs only (skip Wi-Fi and virtual interfaces).
      [ -e "/sys/class/net/$dev/device" ] || continue
      [ -e "/sys/class/net/$dev/wireless" ] && continue
      mac=$(gatewayMac "$gw" "$dev")
      if [ -z "$mac" ]; then
        # Neighbor not resolved yet (fresh link): poke the gateway once.
        ping=/run/wrappers/bin/ping
        [ -x "$ping" ] || ping=${pkgs.iputils}/bin/ping
        "$ping" -c1 -W1 -I "$dev" "$gw" >/dev/null 2>&1
        mac=$(gatewayMac "$gw" "$dev")
      fi
      [ "$mac" = "${deskGatewayMac}" ] && exit 0
    done < <(ip -4 route show default | awk '{ g = ""; d = ""; for (i = 1; i < NF; i++) { if ($i == "via") g = $(i + 1); if ($i == "dev") d = $(i + 1) } print g, d }')

    exit 1
  '';

  # Run from udev / NetworkManager (as root): re-evaluate in the user's session.
  triggerSync = pkgs.writeShellScript "deskflow-desk-trigger" ''
    ${systemctl} start --no-block deskflow-desk-trigger.service
  '';
in {
  config = lib.mkMerge [
    {
      environment.systemPackages = [ deskflow ];

      # Hyprland's portal lacks RemoteDesktop/Clipboard, which Deskflow needs on
      # Wayland. Luminous (wlroots-based) provides them. InputCapture stays with
      # Hyprland's portal: Luminous's covers every screen with a grey layer-shell
      # overlay while capturing, which is unusable for an always-on server.
      xdg.portal.extraPortals = [ luminous ];

      # Luminous asks "Allow 'x' to make remote?" for every RemoteDesktop session
      # (i.e. on each boot). With false it skips the dialog when there's one screen.
      environment.etc."xdg/xdg-desktop-portal-luminous/config.toml".text = ''
        remote_permission_check = false
      '';

      # hyprland-portals.conf overrides `common`, so route these here.
      # This /etc file shadows Hyprland's packaged one, so restate its default.
      xdg.portal.config.hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.RemoteDesktop" = [ "luminous" ];
        "org.freedesktop.impl.portal.Clipboard" = [ "luminous" ];
      };
    }

    # Server: always on in Hyprland sessions; idle until the laptop connects.
    # (Not in Plasma: the KDE portal would prompt.)
    (lib.mkIf isServer {
      # Only reachable over Tailscale; the client connects to the Tailscale IP.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 24800 ];

      systemd.user.services.deskflow-server = {
        description = "Deskflow server";
        wantedBy = [ "hyprland-session.target" ];
        partOf = [ "hyprland-session.target" ];
        # Its clipboard session is served by Luminous; start after it is up.
        wants = [ "xdg-desktop-portal-luminous.service" ];
        after = [ "hyprland-session.target" "xdg-desktop-portal-luminous.service" ];
        serviceConfig = {
          ExecStart = "${deskflow}/bin/deskflow-core server";
          Restart = "always";
          RestartSec = 5;
        };
      };
    })

    # Client: only runs while at the desk. Power and network events re-check.
    (lib.mkIf isClient {
      environment.systemPackages = [ atDesk ];

      systemd.user.services.deskflow-client = {
        description = "Deskflow client (started by deskflow-desk-sync)";
        partOf = [ "hyprland-session.target" ];
        after = [ "hyprland-session.target" ];
        serviceConfig = {
          ExecStart = "${deskflow}/bin/deskflow-core client";
          # The core exits on portal errors; just come back.
          Restart = "always";
          RestartSec = 5;
          # It logs a connect failure every second if the server is unreachable.
          LogRateLimitIntervalSec = 60;
          LogRateLimitBurst = 20;
        };
      };

      systemd.user.services.deskflow-desk-sync = {
        description = "Start/stop Deskflow client depending on whether the laptop is at the desk";
        wantedBy = [ "hyprland-session.target" ];
        after = [ "hyprland-session.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          if ${atDesk}/bin/deskflow-at-desk; then
            ${systemctl} --user start deskflow-client.service
          else
            ${systemctl} --user stop deskflow-client.service
          fi
        '';
      };

      # Bridges root-side events into the user's session; no-op when logged out.
      systemd.services.deskflow-desk-trigger = {
        description = "Re-check Deskflow desk state for ${myOptions.username}";
        serviceConfig.Type = "oneshot";
        script = ''
          ${systemctl} --user --machine=${myOptions.username}@.host start --no-block deskflow-desk-sync.service || true
        '';
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", ENV{POWER_SUPPLY_TYPE}=="Mains", RUN+="${triggerSync}"
      '';

      networking.networkmanager.dispatcherScripts = [{
        type = "basic";
        source = pkgs.writeShellScript "deskflow-desk-dispatch" ''
          case "$2" in
            up|down|dhcp4-change|connectivity-change) ${triggerSync} ;;
          esac
        '';
      }];
    })
  ];
}
