{ lib, ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      #width = 480;
      width = 590;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };
    style = lib.mkForce ''
    /* 050505,515151,b5b5b5,7c7c7c,3c3c3c,272727,848484,737474,343434,1c1c1c */
    @define-color accent #848484; /* Selected color */
    @define-color border #b5b5b5; /* Uh, border     */
    @define-color txt    #ffffff; /* Default Text   */
    @define-color txt2   #272727; /* Selected Text  */
    @define-color bg     #272727; /* Main bg        */
    @define-color bg2    #848484; /* Searchbar      */

    * {
        font-family: 'JetBrains Mono Nerd Font', monospace;
        font-size: 14px;
    }

    /* Window */
    window {
        margin: 0px;
        padding: 10px;
        border: 3px solid @border;
        border-radius: 7px;
        background-color: @bg;
        animation: slideIn 0.5s ease-in-out both;
    }

    /* Slide In */
    @keyframes slideIn {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1;
        }
    }

    /* Inner Box */
    #inner-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: @bg;
        animation: fadeIn 0.5s ease-in-out both;
    }

    /* Fade In */
    @keyframes fadeIn {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1;
        }
    }

    /* Outer Box */
    #outer-box {
        margin: 5px;
        padding: 10px;
        border: none;
        background-color: @bg;
    }

    /* Scroll */
    #scroll {
        margin: 0px;
        padding: 10px;
        border: none;
    }

    /* Input */
    #input {
        margin: 5px;
        padding: 10px;
        border: none;
        color: @txt2;
        background-color: @bg2;
        animation: fadeIn 0.5s ease-in-out both;
    }

    /* Text */
    #text {
        margin: 5px;
        padding: 10px;
        border: none;
        color: @txt;
        animation: fadeIn 0.5s ease-in-out both;
    }

    /* Selected Entry */
    #entry:selected {
      border-radius: 5px 5px 5px 5px;
      background-color: @accent;
    }

    #entry:selected #text {
        color: @txt2;
    }
    '';
  };
}