{...}: {
  flake.nixosModules.cist-schedule = {pkgs, lib, config, ...}: {
    options = {
      settings.cist-schedule = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "cist-sh.pencel.dev";
          description = "Domain name for CIST Schedule Converter";
        };

        port = lib.mkOption {
          type = port;
          default = 8033;
          description = "Internal HTTP listening port for CIST Schedule Converter";
        };
      };
    };

    config = {
      virtualisation.oci-containers.containers.cist-schedule = {
        image = "ghcr.io/pencelheimer/cist-schedule-converter:latest";
        environment = {
          PORT = toString config.settings.cist-schedule.port;
        };
        ports = [
          "127.0.0.1:${toString config.settings.cist-schedule.port}:${toString config.settings.cist-schedule.port}"
        ];

        extraOptions = [ "--label=io.containers.autoupdate=registry" ];
      };

      services.caddy.virtualHosts."http://${config.settings.cist-schedule.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.cist-schedule.port}

          @groups path /groups
          header @groups Cache-Control "public, max-age=86400"

          @schedule path_regexp /groups/.+/schedule
          header @schedule Cache-Control "public, max-age=86400"
        '';
      };
    };
  };
}
