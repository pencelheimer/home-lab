{...}: {
  flake.nixosModules.redlib = {pkgs, lib, config, ...}: {
    options = with lib.types; {
      settings.redlib = {
        domain = lib.mkOption {
          type = str;
          default = "redlib.pencel.dev";
          description = "Domain name for Redlib";
        };

        port = lib.mkOption {
          type = port;
          default = 8082;
          description = "Internal HTTP listening port for Redlib";
        };

        auth-username = lib.mkOption {
          type = str;
          default = "pencelheimer";
          description = "Basic auth username guarding Redlib";
        };

        auth-password-hash = lib.mkOption {
          type = str;
          description = "Bcrypt hash of the basic auth password (set in secrets.nix)";
        };
      };
    };

    config = {
      virtualisation.oci-containers.containers.redlib = {
        image = "ghcr.io/nachtalb/redlib:latest";
        environment = {
          # Enable RSS feeds (this fork adds full RSS support)
          REDLIB_ENABLE_RSS = "on";
          REDLIB_DEFAULT_THEME = "dark";
          REDLIB_DEFAULT_FRONT_PAGE = "default";
          REDLIB_DEFAULT_LAYOUT = "card";
          REDLIB_DEFAULT_POST_SORT = "hot";
          REDLIB_DEFAULT_COMMENT_SORT = "confidence";
          REDLIB_DEFAULT_SHOW_NSFW = "off";
          REDLIB_DEFAULT_BLUR_NSFW = "on";
          REDLIB_DEFAULT_HIDE_AWARDS = "on";
          REDLIB_DEFAULT_CLEAN_URLS = "on";
          REDLIB_DEFAULT_POSTS_PER_PAGE = "25";
        };
        ports = [
          "127.0.0.1:${toString config.settings.redlib.port}:8080"
        ];
      };

      services.caddy.virtualHosts."http://${config.settings.redlib.domain}" = {
        extraConfig = ''
          basic_auth {
            ${config.settings.redlib.auth-username} ${config.settings.redlib.auth-password-hash}
          }
          reverse_proxy 127.0.0.1:${toString config.settings.redlib.port}
        '';
      };
    };
  };
}