{...}: {
  flake.nixosModules.radicale = {pkgs, lib, config, ...}: {
    options = {
      settings.radicale = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "radicale.pencel.dev";
          description = "Domain name for Radicale CalDAV/CardDAV service";
        };

        port = lib.mkOption {
          type = port;
          default = 5232;
          description = "Internal listening port for Radicale";
        };

        htpasswd-file = lib.mkOption {
          type = path;
          description = "Path to htpasswd file for Radicale authentication";
        };
      };
    };

    config = {
      services.radicale = {
        enable = true;
        settings = {
          server = {
            hosts = [ "127.0.0.1:${toString config.settings.radicale.port}" ];
          };
          auth = {
            type = "htpasswd";
            htpasswd_filename = toString config.settings.radicale.htpasswd-file;
            htpasswd_encryption = "bcrypt";
          };
          storage = {
            filesystem_folder = "/var/lib/radicale/collections";
          };
        };
      };

      services.caddy.virtualHosts."http://${config.settings.radicale.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.radicale.port}
        '';
      };
    };
  };
}
