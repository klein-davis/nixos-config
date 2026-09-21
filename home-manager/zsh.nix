{ hostname, config, pkgs, host, lib, ...}: 
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" ]; # Add "fzf-tab" to the plugins list

      theme = "agnoster";
    };
    # Runs for every shell (including nested ones spawned by nix-shell/nix
    # shell), before .zshrc. Captures the PATH we started with so later
    # shells can tell whether nix has prepended anything to it. The `:=`
    # only assigns when unset, and the export makes it inherited by child
    # shells, so a shell spawned *by* nix-shell/nix shell still sees the
    # original pre-nix baseline rather than re-capturing its own (already
    # modified) PATH.
    envExtra = ''
      : ''${ZSH_BASE_PATH:=$PATH}
      export ZSH_BASE_PATH
    '';
    initContent = lib.mkBefore ''
      DISABLE_MAGIC_FUNCTIONS=true
      export "MICRO_TRUECOLOR=1"
      fastfetch

      # Nix shell indicator. nix-shell/nix develop set $IN_NIX_SHELL, but the
      # newer `nix shell` deliberately does not, so fall back to comparing
      # PATH against the baseline captured in .zshenv: if it grew to include
      # a /nix/store entry that wasn't there at shell startup, we're in one.
      # (A plain "PATH contains /nix/store" check isn't safe on its own -
      # some environments already have raw store paths in their base PATH.)
      _nix_shell_rprompt() {
        if [[ -n "$IN_NIX_SHELL" ]] || \
           [[ "$PATH" != "$ZSH_BASE_PATH" && "$PATH" == *"/nix/store"* ]]; then
          RPROMPT="%F{cyan}❄ nix-shell%f"
        else
          RPROMPT=""
        fi
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _nix_shell_rprompt
    '';
    plugins = [
    # {
    #   name = "zsh-vi-mode";
    #   src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
    # }
    {
      name = "fzf-tab";
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
    }
    ];

    # shopt -s dotglob
    shellAliases = {
      # record = "wf-recorder --audio=alsa_output.pci-0000_08_00.6.analog-stereo.monitor -f $HOME/Videos/$(date +'%Y%m%d%H%M%S_1.mp4')";

      # Utils
      #c = "clear";
      cd = "z";
      #tt = "gtrash put";
      # cat = "bat";
      #nano = "micro";
      code = "codium";
      # py = "python";
      #icat = "kitten icat";
      #dsize = "du -hs";
      findw = "grep -rl";

      #l = "eza --icons  -a --group-directories-first -1"; #EZA_ICON_SPACING=2
      #ll = "eza --icons  -a --group-directories-first -1 --no-user --long";
      #tree = "eza --icons --tree --group-directories-first";

      # Nixos
      #cdnix = "cd ~/nixos-config && codium ~/nixos-config";
      ns = "nix-shell --run zsh";
      #nix-shell = "nix-shell --run zsh";
      nix-switch = "sudo nixos-rebuild switch --flake .#${host}";
      nix-list-hosts = "nix flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]'";
      #nix-switchu = "sudo nixos-rebuild switch --upgrade --flake ~/nixos-config#${host}";
      #nix-flake-update = "sudo nix flake update ~/nixos-config#";
      #nix-clean = "sudo nix-collect-garbage && sudo nix-collect-garbage -d && sudo rm /nix/var/nix/gcroots/auto/* && nix-collect-garbage && nix-collect-garbage -d";

      slowcat = "pv -l -L 5 -q";

      # Git
      # ga   = "git add";
      # gaa  = "git add --all";
      # gs   = "git status";
      # gb   = "git branch";
      # gm   = "git merge";
      # gpl  = "git pull";
      # gplo = "git pull origin";
      # gps  = "git push";
      # gpst = "git push --follow-tags";
      # gpso = "git push origin";
      # gc   = "git commit";
      # gcm  = "git commit -m";
      # gcma = "git add --all && git commit -m";
      # gtag = "git tag -ma";
      # gch  = "git checkout";
      # gchb = "git checkout -b";
      # gcoe = "git config user.email";
      # gcon = "git config user.name";

      # python
      #piv = "python -m venv .venv";
      #psv = "source .venv/bin/activate";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
