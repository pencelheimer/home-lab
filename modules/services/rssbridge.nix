{...}: {
  flake.nixosModules.rssbridge = {pkgs, lib, config, ...}: {
    options = with lib.types; {
      settings.rssbridge = {
        domain = lib.mkOption {
          type = str;
          default = "rss-bridge.pencel.dev";
          description = "Domain name for RSS-Bridge";
        };

        auth-username = lib.mkOption {
          type = str;
          description = "HTTP Authentication Username for RSS-Bridge";
        };

        auth-password = lib.mkOption {
          type = str;
          description = "HTTP Authentication Password for RSS-Bridge";
        };

        custom-token = lib.mkOption {
          type = str;
          description = "Custom access token for RSS-Bridge";
        };
      };
    };

    config = {
      services.rss-bridge = {
        enable = true;
        webserver = "caddy";
        virtualHost = "http://${config.settings.rssbridge.domain}";
        config = {
          system = {
            # TODO: enable only essential bridges
            enabled_bridges = [ "*" ];
          };

          authentication = {
            enable = true;
            username = config.settings.rssbridge.auth-username;
            password = config.settings.rssbridge.auth-password;
          };

          access = {
            key = config.settings.rssbridge.custom-token;
          };
        };
      };
    };
  };
}
