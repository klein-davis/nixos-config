{ pkgs, lib, inputs, host, myOptions, ... }:
let
  deskflow = pkgs.deskflow;
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
  imports = [ inputs.hypr-kdeconnect-fix.nixosModules.default ];

  config = lib.mkMerge [
    {
      environment.systemPackages = [ deskflow ];

      # Hyprland's portal lacks RemoteDesktop, which the Deskflow client needs
      # on Wayland. This bridge provides it via virtual-pointer/keyboard + libei.
      services.hypr-kdeconnect-fix = {
        enable = true;
        # Keep default portalUseIn: upstream's metadata test requires the full list,
        # and routing is set explicitly in hyprland-portals.conf below anyway.
        package = (pkgs.callPackage "${inputs.hypr-kdeconnect-fix}/nix/package.nix" { }).overrideAttrs (old: {
          src = inputs.hypr-kdeconnect-fix-src;
          # Bridge only accepts the exact caller exe; on NixOS that's the wrapped binary.
          cmakeFlags = (old.cmakeFlags or []) ++ [
            "-DHKCF_DESKFLOW_EXECUTABLE=${deskflow}/bin/.deskflow-core-wrapped"
          ];
        });
      };

      # The bridge verifies the caller via /proc/<pid>/exe; these options put the
      # user unit in its own namespace, making that readlink fail (session refused).
      # asDropin: otherwise NixOS emits a full unit that shadows the packaged one.
      systemd.user.services.hypr-kdeconnect-portal = {
        overrideStrategy = "asDropin";
        serviceConfig = {
          PrivateTmp = false;
          ProtectSystem = false;
          ProtectHome = false;
        };
      };

      # hyprland-portals.conf overrides `common`, so route RemoteDesktop here too.
      # This /etc file shadows Hyprland's packaged one, so restate its default.
      xdg.portal.config.hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.RemoteDesktop" = [ "hypr-kdeconnect" ];
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
        after = [ "hyprland-session.target" ];
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
