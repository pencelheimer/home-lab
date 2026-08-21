{...}: {
  flake.nixosModules.vaultwarden = {pkgs, lib, config, ...}: {
    options = {
      settings.vaultwarden = {
        domain = lib.mkOption {
          type = lib.types.str;
          default = "vault.pencel.dev";
          description = "Domain name for Vaultwarden";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8222;
          description = "Internal port for Vaultwarden web server";
        };
      };
    };

    config = {
      services.vaultwarden = {
        enable = true;
        config = {
          DOMAIN = "https://${config.settings.vaultwarden.domain}";
          ROCKET_PORT = config.settings.vaultwarden.port;
          ROCKET_ADDRESS = "127.0.0.1";
        };
      };

      services.caddy.virtualHosts."http://${config.settings.vaultwarden.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.vaultwarden.port}
        '';
      };
    };
  };
}
