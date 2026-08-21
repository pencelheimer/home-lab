{...}: {
  flake.nixosModules.miniflux = {pkgs, lib, config, ...}: {
    options = with lib.types; {
      settings.miniflux = {
        domain = lib.mkOption {
          type = str;
          default = "miniflux.pencel.dev";
          description = "Domain name for Miniflux";
        };

        port = lib.mkOption {
          type = port;
          default = 6970;
          description = "Internal port for Miniflux";
        };

        admin-credentials-file = lib.mkOption {
          type = path;
          description = "Path to file containing ADMIN_USERNAME and ADMIN_PASSWORD";
        };
      };
    };

    config = {
      services.miniflux = {
        enable = true;
        createDatabaseLocally = true;
        adminCredentialsFile = config.settings.miniflux.admin-credentials-file;
        config = {
          LISTEN_ADDR = "127.0.0.1:${toString config.settings.miniflux.port}";
          BASE_URL = "https://${config.settings.miniflux.domain}/";
        };
      };

      services.postgresql = {
        ensureDatabases = [ "miniflux" ];
        ensureUsers = [
          {
            name = "miniflux";
            ensureDBOwnership = true;
          }
        ];
      };

      services.caddy.virtualHosts."http://${config.settings.miniflux.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.miniflux.port}
        '';
      };
    };
  };
}
