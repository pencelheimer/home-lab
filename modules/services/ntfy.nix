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

        auth-users = lib.mkOption {
          type = listOf str;
          default = [];
          description = "List of user entries in format 'username:bcrypt-hash:role'";
        };

        auth-access = lib.mkOption {
          type = listOf str;
          default = [];
          description = "List of access control entries in format 'username:topic-pattern:permission'";
        };
      };
    };

    config = {
      services.ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://${config.settings.ntfy.domain}";
          upstream-base-url = "https://ntfy.sh";
          listen-http = "127.0.0.1:${toString config.settings.ntfy.port}";
          behind-proxy = true;

          auth-default-access = "deny-all";
          auth-users = config.settings.ntfy.auth-users;
          auth-access = config.settings.ntfy.auth-access;
          enable-login = true;

          database-url = "postgres:///ntfy-sh?host=/run/postgresql";
          auth-file = "";
          cache-file = "";
        };
      };

      services.postgresql = {
        ensureDatabases = [ "ntfy-sh" ];
        ensureUsers = [
          {
            name = "ntfy-sh";
            ensureDBOwnership = true;
          }
        ];
      };

      services.caddy.virtualHosts."http://${config.settings.ntfy.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.ntfy.port}
        '';
      };
    };
  };
}
