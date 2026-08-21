{...}: {
  flake.nixosModules.navidrome = {pkgs, lib, config, ...}: {
    options = {
      settings.navidrome = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "navidrome.pencel.dev";
          description = "Domain name for Navidrome music server";
        };

        port = lib.mkOption {
          type = port;
          default = 4533;
          description = "Internal listening port for Navidrome";
        };

        music-folder = lib.mkOption {
          type = str;
          default = "/var/lib/navidrome/music";
          description = "Directory containing music files";
        };
      };
    };

    config = {
      services.navidrome = {
        enable = true;
        settings = {
          Address = "127.0.0.1";
          Port = config.settings.navidrome.port;
          MusicFolder = config.settings.navidrome.music-folder;
          DataFolder = "/var/lib/navidrome/data";
        };
      };

      services.caddy.virtualHosts."http://${config.settings.navidrome.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.navidrome.port}
        '';
      };
    };
  };
}
