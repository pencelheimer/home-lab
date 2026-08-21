{...}: {
  flake.nixosModules.copyparty = {pkgs, lib, config, ...}: {
    options = {
      settings.copyparty = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "copyparty.pencel.dev";
          description = "Domain name for Copyparty file server";
        };

        port = lib.mkOption {
          type = port;
          default = 3923;
          description = "Internal listening port for Copyparty";
        };

        volumes = lib.mkOption {
          type = listOf str;
          default = [
            "/var/lib/copyparty/data:/:rw"
          ];
          description = "Volume mappings for Copyparty in format '/local/path:/web/path:flags'";
        };
      };
    };

    config = {
      services.copyparty = {
        enable = true;
        settings = {
          i = "127.0.0.1";
          p = config.settings.copyparty.port;
          v = config.settings.copyparty.volumes;
        };
      };

      services.caddy.virtualHosts."http://${config.settings.copyparty.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.copyparty.port}
        '';
      };
    };
  };
}
