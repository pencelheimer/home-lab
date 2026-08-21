{...}: {
  flake.nixosModules.rssbridge = {pkgs, lib, config, ...}: {
    options = with lib.types; {
      settings.rssbridge = {
        domain = lib.mkOption {
          type = str;
          default = "rssbridge.pencel.dev";
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

      services.caddy.virtualHosts."http://${config.settings.rssbridge.domain}" = {
        extraConfig = ''
          root * ${pkgs.rss-bridge}
          php_fastcgi unix//run/phpfpm/rss-bridge.sock
          file_server
        '';
      };
    };
  };
}
