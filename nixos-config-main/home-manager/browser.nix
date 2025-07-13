{ config, pkgs, inputs, myOptions, ... }: {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [pkgs.tridactyl-native];
    profiles = {
      "${myOptions.username}" = {
        id = 0;
        isDefault = true;
        name = "${myOptions.username}";
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          bitwarden
          # refined-github
          # sponsorblock
          # mal-sync
          # to-google-translate
          # foxyproxy-standard
          # istilldontcareaboutcookies
          # localcdn
          # clearurls
          # privacy-badger
          # don-t-fuck-with-paste
          # skip-redirect
          # search-by-image
          # tridactyl
          ublock-origin
          # inputs.firefox-addons.packages.${pkgs.system}."10ten-ja-reader"
        ];
        settings = {
          # GENERAL
          "browser.startup.page" = "https://71zenith.github.io/";
          "browser.display.use_document_fonts" = 0;
          "browser.ctrlTab.sortByRecentlyUsed" = false;
          "browser.theme.toolbar-theme" = 0;
          "general.autoScroll" = true;
          "extensions.autoDisableScopes" = 0;
          "extensions.allowPrivateBrowsingByDefault" = true;
          "browser.toolbars.bookmarks.visibility" = "never";

          # TELEMETRY
          "browser.ping-centre.telemetry" = false;
          "devtools.onboarding.telemetry.logged" = false;
          "extensions.webcompat-reporter.enabled" = false;
          "browser.urlbar.eventTelemetry.enabled" = false;

          # PERFS
          "media.rdd-ffmpeg.enabled" = true;
          "widget.dmabuf.force-enabled" = true;
          "media.ffvpx.enabled" = false;
          "media.rdd-vpx.enabled" = false;

          # TWEAKS
          "browser.cache.memory.capacity" = -1;
          "middlemouse.paste" = false;
          "network.dns.echconfig.enabled" = true;
          "browser.tabs.loadBookmarksInTabs" = true;
          "browser.urlbar.maxRichResults" = true;

          # PRIVACY
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "app.normandy.enabled" = false;
        };

        # bookmarks = [ ];

        # search = {
        #   default = "Brave";
        #   force = true;
        #   engines = {
        #     "Brave" = {
        #       urls = [{template = "https://search.brave.com/search?q={searchTerms}";}];
        #       definedAliases = ["@b"];
        #       iconUpdateURL = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
        #     };
        #     "GitHub" = {
        #       urls = [{template = "https://github.com/search?q={searchTerms}&type=code";}];
        #       definedAliases = ["@gh"];
        #     };
        #     "Nix Packages" = {
        #       urls = [{template = "https://search.nixos.org/packages?channel=unstable&type=packages&query={searchTerms}";}];
        #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        #       definedAliases = ["@np"];
        #     };
        #     "Nix Options" = {
        #       urls = [{template = "https://search.nixos.org/options?channel=unstable&type=packages&query={searchTerms}";}];
        #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        #       definedAliases = ["@no"];
        #     };
        #     "YouTube" = {
        #       iconUpdateURL = "https://youtube.com/favicon.ico";
        #       updateInterval = 24 * 60 * 60 * 1000;
        #       urls = [{template = "https://www.youtube.com/results?search_query={searchTerms}";}];
        #       definedAliases = ["@yt"];
        #     };
        #     "Google".metaData.alias = "g";
        #   };
        # };
      };
    };
  };
}