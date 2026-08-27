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

        username = lib.mkOption {
          type = str;
          description = "Username for ESPHome Dashboard authentication";
        };

        password = lib.mkOption {
          type = str;
          description = "Password for ESPHome Dashboard authentication";
        };
      };
    };

    config = {
      virtualisation.oci-containers.containers.esphome = {
        image = "ghcr.io/esphome/esphome:latest";
        environment = {
          ESPHOME_USERNAME = config.settings.esphome.username;
          ESPHOME_PASSWORD = config.settings.esphome.password;
        };
        volumes = [
          "/var/lib/esphome:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/esphome 0755 root root -"
      ];

      networking.firewall.allowedTCPPorts = [ config.settings.esphome.port ];

      services.caddy.virtualHosts."http://${config.settings.esphome.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.esphome.port}
        '';
      };
    };
  };
}
