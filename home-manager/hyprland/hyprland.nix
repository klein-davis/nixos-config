{ inputs, pkgs, ...}: 
{
  home.packages = with pkgs; [
    # swww
    # swaybg
    inputs.hypr-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
    hyprpicker
    grim
    slurp
    swappy
    wl-clip-persist
    wf-recorder
    wayland
    hyprsunset
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    # Upstream's nix/default.nix supplies `glaze-hyprland` (nixpkgs' glaze,
    # version-compatible) as a buildInput, but find_package(glaze) in
    # CMakeLists.txt isn't locating it, so CMake falls back to FetchContent
    # git-cloning glaze live - which Nix's sandboxed build blocks (no
    # network). Force FetchContent to use the already-fetched nixpkgs glaze
    # source instead, sidestepping the live clone entirely.
    package = (inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland).overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ [
        "-DFETCHCONTENT_SOURCE_DIR_GLAZE=${pkgs.glaze.src}"
      ];
      # Upstream's postInstall wraps Hyprland with hyprland-guiutils (welcome/
      # dialog/run/update-screen helpers) on PATH. hyprland-guiutils fails to
      # build right now - it's compiled with gcc 15 but links against
      # hyprtoolkit's libhyprtoolkit.so, which was built with gcc 16 and
      # exports std::format symbols the gcc 15 libstdc++ doesn't have
      # (upstream ABI mismatch between the two sibling flakes, not something
      # fixable from this config). Drop hyprland-guiutils from the PATH wrap
      # so Hyprland itself still builds; this only loses those optional
      # helper utilities, not core compositor functionality.
      postInstall = ''
        wrapProgram $out/bin/Hyprland \
          --suffix PATH : ${pkgs.lib.makeBinPath [ pkgs.binutils pkgs.pciutils pkgs.pkgconf ]}
      '';
    });
    enable = true;
    configType = "lua";
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
    
  };
}
