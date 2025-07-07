{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.programs.shyfox;
  shyfoxProfile = pkgs.runCommand "shyfox-profile" { } ''
    mkdir -p $out
    mkdir -p $out/chrome
    cp -r ${cfg.shyfox}/chrome/* $out/chrome
    cp ${cfg.shyfox}/user.js $out/user.js
  '';
  sideberyConfig = builtins.fromJSON (builtins.readFile cfg.sideberyConfigPath);
  shyfoxPkg = pkgs.fetchFromGitHub {
    owner = "blockdoth";
    repo = "ShyFox";
    rev = "fba147660a1b374f00e50df59b525f7c7bb5a4e5";
    sha256 = "sha256-YfPDJHoyA0tj73rnDOqI65n0bAh8hSTPnXLDEkzQVpg=";
  };
in
{
  options.programs.shyfox = {
    enable = lib.mkEnableOption "Enable custom Firefox setup";
    shyfox = lib.mkOption {
      type = lib.types.package;
      default = shyfoxPkg;
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

    home.file.".mozilla/firefox/${cfg.profile}" = {
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

      profiles.${cfg.profile} = {
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
            "youtube" = {
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
              sidebarCSS = sideberyConfig.sidebarCSS;
              contextMenu = sideberyConfig.contextMenu;
              keybindings = sideberyConfig.keybindings;
            };
          };
        };
      };
    };
  };
}
