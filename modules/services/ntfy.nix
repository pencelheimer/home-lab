{...}: {
  flake.nixosModules.ntfy = {pkgs, lib, config, ...}: {
    options = {
      settings.ntfy = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "ntfy.pencel.dev";
          description = "Domain name for ntfy notification service";
        };

        port = lib.mkOption {
          type = port;
          default = 8085;
          description = "Internal HTTP listening port for ntfy";
        };

        auth-default-access = lib.mkOption {
          type = str;
          default = "deny-all";
          description = "Default access level for unauthenticated ntfy requests";
        };
      };
    };

    config = {
      services.ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://${config.settings.ntfy.domain}";
          listen-http = "127.0.0.1:${toString config.settings.ntfy.port}";
          auth-default-access = config.settings.ntfy.auth-default-access;
        };
      };

      services.caddy.virtualHosts."http://${config.settings.ntfy.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.ntfy.port}
        '';
      };
    };
  };
}
