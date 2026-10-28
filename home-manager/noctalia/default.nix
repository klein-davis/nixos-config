{ inputs, pkgs, ... } : {

  imports = [ inputs.noctalia.homeModules.default ];

  home.file.".local/state/noctalia/settings.toml" = {
    source = ./settings.toml;
    force = true;
    mutable = true;
  };

  home.packages = [
    # Diffs Noctalia's GUI-written settings.toml overrides against the
    # config.toml generated from this file's `settings`, and prints
    # ready-to-paste Nix snippets for anything not yet declared here.
    (pkgs.writers.writePython3Bin "noctalia-diff-settings"
      { libraries = [ pkgs.python3Packages.tomlkit ]; }
      (builtins.readFile ../scripts/noctalia-diff-settings.py))
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "wallpaper"; # pull the palette from the desktop wallpaper
        templates = {
          enable_builtin_templates = true;
          # Only apps we actually use; empty builtin_ids applies nothing
          # even with enable_builtin_templates = true.
          builtin_ids = [ "gtk3" "gtk4" "qt" "kcolorscheme" "hyprland" "kitty" "cava" "btop" ];
        };
      };
      wallpaper = {
        enabled = true;
        directory = "~/Pictures/wallpapers";
      };
    };
  };
}