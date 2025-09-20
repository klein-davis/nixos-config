{ config, pkgs, ... }: 
{
programs.yazi = {
    enable = true;

    # Fetch and package the mount.yazi plugin from its Git repository
    plugins = {
      "mount.yazi" = pkgs.yaziPlugins.mount;
      "chmod.yazi" = pkgs.yaziPlugins.chmod;
      "lazygit.yazi" = pkgs.yaziPlugins.lazygit;
      "mediainfo.yazi" = pkgs.yaziPlugins.mediainfo;
      # "no-status.yazi" = pkgs.yaziPlugins.no-status;
      "ouch.yazi" = pkgs.yaziPlugins.ouch;
      "restore.yazi" = pkgs.yaziPlugins.restore;
      "smart-enter.yazi" = pkgs.yaziPlugins.smart-enter;
      "toggle-pane.yazi" = pkgs.yaziPlugins.toggle-pane;
    };

    keymap.manager.prepend_keymap = [
      {
        on = "M";
        run = "plugin mount";
        desc = "Show mount manager";
      }
    ];
  };
}