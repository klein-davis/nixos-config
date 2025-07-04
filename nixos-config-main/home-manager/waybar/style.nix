{ config, ... }:
let custom = {
    font = "JetBrainsMono Nerd Font";
    font_size = "15px";
    font_weight = "bold";
    #text_color = "#cdd6f4";
    #secondary_accent= "89b4fa";
    #tertiary_accent = "f5f5f5";
    #background = "53d6d3";

    # text_color = "ffffff";
    # secondary_accent= "53d6d3";
    # tertiary_accent = "53d6d3";
    # background = "2c2c2c";
    # background_highlight = "4c4c4c";

    text_color = config.lib.stylix.colors.base08;
    background = config.lib.stylix.colors.base0D;
    background_highlight = config.lib.stylix.colors.base0C;

    opacity = "0.5";
};
in 
{
  programs.waybar.style = ''

    * {
        border: none;
        border-radius: 0;
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: JetBrains Mono;
        font-weight: bold; 
        min-height: 10px;
    }

    window#waybar {
        background: transparent;
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    #workspaces {
        margin-right: 8px;
        border-radius: 10px;
        transition: none;
        background: #${custom.background};
    }

    /* Inactive */
    #workspaces button {
        transition: none;
        color: #${custom.text_color};
        background: transparent;
        padding: 5px;
        font-size: ${custom.font_size};
    }

    #workspaces button.persistent {
        color: #00ff00;
        font-size: ${custom.font_size};
    }

    /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
    #workspaces button:hover {
        transition: none;
        box-shadow: inherit;
        text-shadow: inherit;
        border-radius: inherit;
        background: #${custom.background_highlight};
    }

    #workspaces button.active {
        background: #${custom.background_highlight};
        color: #${custom.text_color};
        border-radius: inherit;
    }

    #language {
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px 10px 10px 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }
    /*
    #keyboard-state {
        margin-right: 8px;
        padding-right: 16px;
        border-radius: 0px 10px 10px 0px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }*/

    #custom-pacman {
        padding-left: 16px;
        padding-right: 8px;
        border-radius: 10px 0px 0px 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #custom-mail {
        margin-right: 8px;
        padding-right: 16px;
        border-radius: 0px 10px 10px 0px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #submap {
        padding-left: 16px;
        padding-right: 16px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #clock {
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px 10px 10px 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }
    /*
    #custom-weather {
        padding-right: 16px;
        border-radius: 0px 10px 10px 0px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }*/

    #pulseaudio {
        margin-right: 8px;
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #pulseaudio.muted {
        background-color: #90b1b1;
        color: #2a5c45;
    }

    #custom-mem {
        margin-right: 8px;
        padding-left: 16px;
        padding-right: 16px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #cpu {
        margin-right: 8px;
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #temperature {
        margin-right: 8px;
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #temperature.critical {
        background-color: #eb4d4b;
    }

    #backlight {
        margin-right: 8px;
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #battery {
        margin-right: 8px;
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    #battery.charging {
        color: #${custom.text_color};
        background-color: #26A65B;
    }

    #battery.warning:not(.charging) {
        background-color: #ffbe61;
        color: black;
    }

    #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #${custom.text_color};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    #tray {
        padding-left: 8px;
        padding-right: 8px;
        border-radius: 10px;
        transition: none;
        color: #${custom.text_color};
        background: #${custom.background};
    }

    @keyframes blink {
        to {
            background-color: #${custom.text_color};
            color: #000000;
        }
    }
  '';
}
