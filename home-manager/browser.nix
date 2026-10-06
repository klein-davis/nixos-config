{ config, pkgs, inputs, myOptions, pkgsBundle, ... }: {

  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.firefox = {
    enable = true;
    package = pkgsBundle.pkgs-main.firefox;
    nativeMessagingHosts = [pkgs.tridactyl-native];
    # Pinned explicitly: the real profile data lives here, and the firefox
    # package wrapper doesn't support appDataDir, so the XDG default would
    # silently stop applying anyway (see the profile-fork fix from 2026-10-03).
    configPath = ".mozilla/firefox";
    profiles = {
      "${myOptions.username}" = {
        id = 0;
        isDefault = true;
        name = "${myOptions.username}";
        # Matches the StoreID Firefox already assigned in ~/.mozilla/firefox/Profile Groups/,
        # so home-manager's generated profiles.ini doesn't orphan the live profile group.
        storeId = "f5cbd65f";
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          bitwarden
          clearurls
          don-t-fuck-with-paste
          foxyproxy-standard
          istilldontcareaboutcookies
          localcdn
          privacy-badger
          refined-github
          skip-redirect
          sponsorblock
          to-google-translate
          ublock-origin
        ];
        settings = {
          # GENERAL
          "browser.display.use_document_fonts" = 0;
          "browser.ctrlTab.sortByRecentlyUsed" = false;
          "browser.theme.toolbar-theme" = 0;
          "general.autoScroll" = true;
          "extensions.autoDisableScopes" = 0;
          "extensions.allowPrivateBrowsingByDefault" = true;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.startup.page" = 3; # Previously open tabs

          # URL BAR
          "browser.urlbar.suggest.history" = true;

          # PASSWORDS
          "signon.rememberSignons" = false;

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
           "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;

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

        search = {
          default = "Brave";
          force = true;
          engines = {
            "Brave" = {
              urls = [{template = "https://search.brave.com/search?q={searchTerms}";}];
              definedAliases = ["@b"];
              icon = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
            };
            "GitHub" = {
              urls = [{template = "https://github.com/search?q={searchTerms}&type=code";}];
              definedAliases = ["@gh"];
            };
            "Nix Packages" = {
              urls = [{template = "https://search.nixos.org/packages?channel=unstable&type=packages&query={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };
            "Nix Options" = {
              urls = [{template = "https://search.nixos.org/options?channel=unstable&type=packages&query={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@no"];
            };
            "youtube" = {
              icon = "https://youtube.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000;
              urls = [{template = "https://www.youtube.com/results?search_query={searchTerms}";}];
              definedAliases = ["@yt"];
            };
            "google".metaData.alias = "g";
          };
        };
      };
    };
  };
}