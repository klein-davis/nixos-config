{ pkgs, inputs, ... }:
let
  deskflow = pkgs.deskflow;
in {
  imports = [ inputs.hypr-kdeconnect-fix.nixosModules.default ];

  environment.systemPackages = [ deskflow ];

  networking.firewall = {
    allowedTCPPorts = [ 24800 ];
    allowedUDPPorts = [ 24800 ];
  };

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
