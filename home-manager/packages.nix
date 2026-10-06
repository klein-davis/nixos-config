{ inputs, pkgs, pkgsBundle, myOptions, ... }:
{
  home.packages = (with pkgs; [
    (pkgs.writeShellScriptBin "envssh" (builtins.readFile ./scripts/envssh.sh))
    (pkgs.writeShellScriptBin "pia-switch" (builtins.readFile ./scripts/pia-switch.sh))
    (pkgs.writeShellScriptBin "lunet-setup" (builtins.readFile ./scripts/lunet-setup.sh))

    # Talk to Home Assistant's Assist conversation agent from a terminal.
    # Setup/usage: ha-assist --help (or see the top-of-file docstring).
    (pkgs.writers.writePython3Bin "ha-assist" { }
      (builtins.readFile ./scripts/ha-assist.py))

    # Find/kill processes keeping a directory or mount busy, then unmount it.
    # Setup/usage: dirbusy --help (or see the top-of-file docstring).
    # Needs psmisc's `fuser` explicitly: the `fuser` on $PATH is BusyBox's,
    # which lacks -v/-m labeled output and multi-file support.
    (pkgs.writers.writePython3Bin "dirbusy" { }
      (builtins.replaceStrings
        [ "@FUSER@" ]
        [ "${pkgs.psmisc}/bin/fuser" ]
        (builtins.readFile ./scripts/dirbusy.py)))
  ]);
}
