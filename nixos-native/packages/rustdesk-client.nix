{ pkgs, ... }:
let
  # Wayland capture runs through GStreamer's pipewiresrc, which the packaged
  # wrapper's GST_PLUGIN_SYSTEM_PATH_1_0 leaves out ("gst-plugin:unavailable:pipewiresrc").
  rustdesk = pkgs.symlinkJoin {
    name = "rustdesk-pipewire";
    paths = [ pkgs.rustdesk ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/rustdesk \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${pkgs.pipewire}/lib/gstreamer-1.0 \
        --set GDK_BACKEND x11
    '';
  };

  # RustDesk's "Discovered" tab only pings the LAN broadcast address, which
  # Tailscale doesn't carry. Ping each online tailnet peer's discovery port
  # (UDP 21119) directly instead and merge the replies into the file that tab reads.
  tailnetDiscovery = pkgs.writers.writePython3Bin "rustdesk-tailnet-discovery" { flakeIgnore = [ "E501" "E741" ]; } ''
    import json
    import os
    import socket
    import subprocess
    import time
    import tomllib

    PORT = 21119
    PEERS_FILE = os.path.expanduser("~/.config/rustdesk/RustDesk_lan_peers.toml")
    INTERVAL = 15


    def varint(n):
        out = bytearray()
        while True:
            b = n & 0x7F
            n >>= 7
            out.append(b | (0x80 if n else 0))
            if not n:
                return bytes(out)


    def read_varint(buf, i):
        n = shift = 0
        while True:
            b = buf[i]
            i += 1
            n |= (b & 0x7F) << shift
            shift += 7
            if not b & 0x80:
                return n, i


    def fields(buf):
        i = 0
        while i < len(buf):
            tag, i = read_varint(buf, i)
            kind = tag & 7
            if kind == 2:
                ln, i = read_varint(buf, i)
                yield tag >> 3, buf[i:i + ln]
                i += ln
            elif kind == 0:
                _, i = read_varint(buf, i)
            else:
                return


    # RendezvousMessage{ peer_discovery(22) = PeerDiscovery{ cmd(1) = "ping" } }
    inner = b"\x0a\x04ping"
    PING = varint((22 << 3) | 2) + varint(len(inner)) + inner


    def tailnet_ips():
        out = subprocess.run(["tailscale", "status", "--json"], capture_output=True, text=True, timeout=10).stdout
        peers = json.loads(out).get("Peer") or {}
        return [ip for p in peers.values() if p.get("Online") for ip in p.get("TailscaleIPs", []) if "." in ip]


    def probe(ips):
        found = {}
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(0.5)
        for ip in ips:
            sock.sendto(PING, (ip, PORT))
        deadline = time.time() + 3
        while time.time() < deadline:
            try:
                data, (ip, _) = sock.recvfrom(2048)
            except socket.timeout:
                continue
            for num, body in fields(data):
                if num != 22:
                    continue
                info = {n: v.decode(errors="replace") for n, v in fields(body)}
                if info.get(1) == "pong" and info.get(3):
                    found[info[3]] = {"ip": ip, "mac": info.get(2, ""), "username": info.get(4, ""), "hostname": info.get(5, ""), "platform": info.get(6, "")}
        return found


    def q(v):
        return json.dumps(v)


    def load():
        try:
            with open(PEERS_FILE, "rb") as f:
                return tomllib.load(f).get("peers", [])
        except (OSError, tomllib.TOMLDecodeError):
            return []


    def store(peers):
        lines = []
        for p in peers:
            lines.append("[[peers]]")
            for k in ("id", "username", "hostname", "platform"):
                lines.append(f"{k} = {q(p.get(k, ""))}")
            lines.append(f"online = {"true" if p.get("online") else "false"}")
            lines.append("")
            lines.append("[peers.ip_mac]")
            for ip, mac in (p.get("ip_mac") or {}).items():
                lines.append(f"{q(ip)} = {q(mac)}")
            lines.append("")
        os.makedirs(os.path.dirname(PEERS_FILE), exist_ok=True)
        tmp = PEERS_FILE + ".tmp"
        with open(tmp, "w") as f:
            f.write("\n".join(lines) if lines else "peers = []\n")
        os.replace(tmp, PEERS_FILE)


    def main():
        while True:
            try:
                ips = tailnet_ips()
                found = probe(ips)
                tail = {ip for ip in ips}
                peers = load()
                seen = set()
                for p in peers:
                    hit = found.get(p.get("id"))
                    if hit:
                        p["online"] = True
                        p["hostname"], p["username"], p["platform"] = hit["hostname"], hit["username"], hit["platform"]
                        p.setdefault("ip_mac", {})[hit["ip"]] = hit["mac"]
                        seen.add(p["id"])
                    elif tail & set((p.get("ip_mac") or {}).keys()):
                        p["online"] = False
                for pid, hit in found.items():
                    if pid not in seen:
                        peers.insert(0, {"id": pid, "username": hit["username"], "hostname": hit["hostname"], "platform": hit["platform"], "online": True, "ip_mac": {hit["ip"]: hit["mac"]}})
                store(peers)
            except Exception as e:
                print("discovery failed:", e, flush=True)
            time.sleep(INTERVAL)


    main()
  '';
in {
  environment.systemPackages = [ rustdesk ];

  # Both machines accept incoming RustDesk sessions, so each can control the other.
  # The ID/rendezvous server is the desktop's (see ../rustdesk.nix); the permanent
  # password and server key live in ~/.config/rustdesk (GUI-managed, not in the store).
  # Capture goes through Luminous (see deskflow.nix), which neither prompts for
  # RemoteDesktop nor for ScreenCast restore, so no screen picker appears.
  # On Wayland, 1.5.0 injects mouse and keyboard through uinput devices owned by a
  # root `rustdesk --service` (without it: "Failed to update mouse resolution: No such
  # file or directory" and remote input is dropped). That service also starts the
  # user's `--server` itself (via sudo, killing any other --server), so there is no
  # separate server unit. It needs sudo from /run/wrappers and ps/loginctl on PATH.
  systemd.services.rustdesk = {
    description = "RustDesk service (uinput input and the user's server)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "systemd-logind.service" ];
    path = [ "/run/wrappers" pkgs.coreutils pkgs.procps pkgs.gawk pkgs.findutils pkgs.gnugrep pkgs.systemd ];
    serviceConfig = {
      ExecStart = "${rustdesk}/bin/rustdesk --service";
      Restart = "always";
      RestartSec = 5;
      KillMode = "mixed";
    };
  };

  # The service starts the server through `sudo -u <user> env ...`, which drops the
  # environment, including the GStreamer path set by the wrapper above (without it:
  # "could not load pipewiresrc"). Let root's sudo keep that one variable.
  security.sudo-rs.extraConfig = ''
    Defaults:root env_keep += "GST_PLUGIN_SYSTEM_PATH_1_0"
  '';

  # Restart with Luminous: when it aborts (e.g. a monitor wakes from DPMS and its
  # wl_output is recreated) RustDesk's long-lived capturer is left dead and every
  # later session fails with "Failed to get capturer display info". Killing the
  # server is enough: the root service respawns it within a second.
  systemd.user.services.rustdesk-restart-with-luminous = {
    description = "Restart the RustDesk server whenever Luminous restarts";
    wantedBy = [ "hyprland-session.target" ];
    partOf = [ "hyprland-session.target" "xdg-desktop-portal-luminous.service" ];
    after = [ "hyprland-session.target" "xdg-desktop-portal-luminous.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "-${pkgs.procps}/bin/pkill -u %U -f 'rustdesk --server'";
    };
  };

  # Luminous's cast targets a wl_output that Hyprland destroys and recreates when a
  # monitor wakes from DPMS. The next connection then trips a Wayland protocol error
  # and Luminous aborts, failing that first attempt ("Failed to get capturer display
  # info"); the retry works only because systemd has restarted it. Restart it (and
  # RustDesk, via partOf) as soon as a monitor is added so no stale target is left.
  systemd.user.services.luminous-refresh-on-monitor-add = {
    description = "Restart Luminous when Hyprland recreates an output";
    wantedBy = [ "hyprland-session.target" ];
    partOf = [ "hyprland-session.target" ];
    after = [ "hyprland-session.target" ];
    path = [ pkgs.socat pkgs.systemd pkgs.coreutils ];
    script = ''
      sock=$(ls -t "$XDG_RUNTIME_DIR"/hypr/*/.socket2.sock | head -n1)
      last=0
      socat -u "UNIX-CONNECT:$sock" - | while IFS= read -r line; do
        case "$line" in
          monitoraddedv2'>>'*)
            now=$(date +%s)
            # one wake adds several outputs; restart once per burst
            if [ $((now - last)) -ge 10 ]; then
              sleep 2
              systemctl --user restart xdg-desktop-portal-luminous.service
              last=$(date +%s)
            fi
            ;;
        esac
      done
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.user.services.rustdesk-tailnet-discovery = {
    description = "Find RustDesk peers on the tailnet for the Discovered tab";
    wantedBy = [ "hyprland-session.target" ];
    partOf = [ "hyprland-session.target" ];
    path = [ pkgs.tailscale ];
    serviceConfig = {
      ExecStart = "${tailnetDiscovery}/bin/rustdesk-tailnet-discovery";
      Restart = "always";
      RestartSec = 10;
    };
  };

  # Peers reach each other over Tailscale only.
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 21118 ];
    allowedUDPPorts = [ 21116 21119 ]; # 21119: LAN-style discovery pings
  };
}
