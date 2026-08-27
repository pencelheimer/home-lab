{...}: {
  flake.nixosModules.home-assistant = {pkgs, lib, config, ...}: {
    options = {
      settings.home-assistant = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "home-assistant.pencel.dev";
          description = "Domain name for Home Assistant";
        };

        port = lib.mkOption {
          type = port;
          default = 8123;
          description = "Listening port for Home Assistant";
        };
      };
    };

    config = {
      virtualisation.oci-containers.containers.homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        environment = {
          TZ = "Europe/Kyiv";
        };
        volumes = [
          "/var/lib/homeassistant:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
          "--device=/dev/bus/usb"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/homeassistant 0755 root root -"
      ];

      networking.firewall.allowedTCPPorts = [ config.settings.home-assistant.port ];

      services.caddy.virtualHosts."http://${config.settings.home-assistant.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.home-assistant.port}
        '';
      };
    };
  };
}
