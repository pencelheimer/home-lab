{...}: {
  flake.nixosModules.qbittorrent = {pkgs, lib, config, ...}: {
    options = {
      settings.qbittorrent = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "qbittorrent.pencel.dev";
          description = "Domain name for qBittorrent Web UI";
        };

        port = lib.mkOption {
          type = port;
          default = 43000;
          description = "Web UI port for qBittorrent";
        };
      };
    };

    config = {
      services.qbittorrent = {
        enable = true;
        webuiPort = config.settings.qbittorrent.port;
      };

      services.caddy.virtualHosts."http://${config.settings.qbittorrent.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.qbittorrent.port}
        '';
      };
    };
  };
}
