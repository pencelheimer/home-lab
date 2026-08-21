{...}: {
  flake.nixosModules.cloudflared = {pkgs, lib, config, ...}: {
    options = {
      settings.cloudflared = {
        tunnel-id = lib.mkOption {
          type = lib.types.str;
          description = "Cloudflare Tunnel ID";
        };
        credentials-file = lib.mkOption {
          type = lib.types.path;
          description = "Path to Cloudflare Tunnel credentials file";
        };
      };
    };

    config = {
      services.cloudflared = {
        enable = true;
        tunnels = {
          "${config.settings.cloudflared.tunnel-id}" = {
            credentialsFile = config.settings.cloudflared.credentials-file;
            ingress = {
              "pencel.dev" = "http://localhost:80";
              "*.pencel.dev" = "http://localhost:80";
            };
            default = "http://localhost:80";
          };
        };
      };
    };
  };
}
