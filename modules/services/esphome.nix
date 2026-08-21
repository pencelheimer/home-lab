{...}: {
  flake.nixosModules.esphome = {pkgs, lib, config, ...}: {
    options = {
      settings.esphome = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "esphome.pencel.dev";
          description = "Domain name for ESPHome Dashboard";
        };

        port = lib.mkOption {
          type = port;
          default = 6052;
          description = "Listening port for ESPHome Dashboard";
        };
      };
    };

    config = {
      virtualisation.oci-containers.containers.esphome = {
        image = "ghcr.io/esphome/esphome:latest";
        volumes = [
          "/var/lib/esphome:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
      };

      services.caddy.virtualHosts."http://${config.settings.esphome.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.esphome.port}
        '';
      };
    };
  };
}
