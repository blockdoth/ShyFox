{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.programs.browsers.firefox;
  shyfoxProfile = pkgs.runCommand "shyfox-profile" { } ''
    mkdir -p $out
    mkdir -p $out/chrome
    cp -r ${cfg.shyfox}/chrome/* $out/chrome
    cp ${cfg.shyfox}/user.js $out/user.js
  '';
  sideberyConfig = builtins.fromJSON (builtins.readFile cfg.sideberyConfigPath);
  defaultProfile = "default";
in
{
  options.modules.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Enable custom Firefox setup";
    shyfox = lib.mkOption {
      type = lib.types.package;
      description = "The ShyFox package providing chrome and user.js";
    };
    sideberyConfigPath = lib.mkOption {
      type = lib.types.path;
      default = ./sidebery-config.json;
      description = "Path to Sidebery config JSON file";
    };
    profile = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Profile name";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BROWSER = "firefox";

    home.file.".mozilla/firefox/${defaultProfile}" = {
      source = shyfoxProfile;
      recursive = true;
    };

    programs.firefox = {
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "never";
        SearchBar = "unified";
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };

      profiles.${defaultProfile} = {
        isDefault = true;

       search = {
          force = true;
          engines = {

            "Nix Packages" = {
              definedAliases = [ "@nix" ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };
            "YouTube" = {
              definedAliases = [ "@yt" ];
              icon = "https://www.youtube.com/s/desktop/2253fa3d/img/logos/favicon.ico";
              urls = [
                {
                  template = "https://www.youtube.com/results";
                  params = [
                    {
                      name = "search_query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
            };

            "ChatGPT" = {
              definedAliases = [ "@gpt" ];
              icon = "https://chat.openai.com/favicon.ico";
              urls = [
                {
                  template = "https://chat.openai.com/?q={searchTerms}";
                }
              ];
            };
          };
        };

        extensions = {
          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            bitwarden
            clearurls
            dark-mode-website-switcher
            linkwarden
            return-youtube-dislikes
            sidebery
            sponsorblock
            ublock-origin
            userchrome-toggle-extended
            videospeed
            i-dont-care-about-cookies
          ];
        };

        settings = {
          "extensions.autoDisableScopes" = 0;
          "{3c078156-979c-498b-8990-85f7987dd929}" = {
            force = true;
            settings = {
              settings = sideberyConfig.settings;
              sidebar = sideberyConfig.sidebar;
              contextMenu = sideberyConfig.contextMenu;
              keybindings = sideberyConfig.keybindings;
            };
          };
        };
      };
    };
  };
}
