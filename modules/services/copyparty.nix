{...}: {
  flake.nixosModules.copyparty = {pkgs, lib, config, ...}: {
    options = {
      settings.copyparty = with lib.types; {
        domain = lib.mkOption {
          type = str;
          default = "copyparty.pencel.dev";
          description = "Domain name for Copyparty file server";
        };

        port = lib.mkOption {
          type = port;
          default = 3923;
          description = "Internal listening port for Copyparty";
        };

        accounts = lib.mkOption {
          type = attrsOf (submodule {
            options = {
              passwordFile = lib.mkOption {
                type = path;
                description = "Path to file containing the user's password";
              };
            };
          });
          default = {};
          description = "Copyparty user accounts";
        };

        volumes = lib.mkOption {
          type = attrsOf (submodule {
            options = {
              path = lib.mkOption {
                type = path;
                description = "Filesystem path to share";
              };
              access = lib.mkOption {
                type = attrsOf (oneOf [ str (listOf str) ]);
                default = {};
                description = "Access permissions (r, rw, etc.)";
              };
              flags = lib.mkOption {
                type = attrsOf (oneOf [ bool int str ]);
                default = {};
                description = "Volume flags (fk, scan, e2d, d2t, nohash, etc.)";
              };
            };
          });
          default = {};
          description = "Copyparty volumes";
        };
      };
    };

    config = {
      services.copyparty = {
        enable = true;

        settings = {
          i = "127.0.0.1";
          p = config.settings.copyparty.port;

          # real ip from cloudflare
          xff-hdr = "cf-connecting-ip"; # header to read client IP from
          xff-src = "0.0.0.0/0";        # trust headers from cloudflare
          rproxy = 1;                   # single ip in header
        };

        accounts = lib.mapAttrs (_: acc: acc // { passwordFile = toString acc.passwordFile; }) config.settings.copyparty.accounts;
        volumes = config.settings.copyparty.volumes;
      };

      services.caddy.virtualHosts."http://${config.settings.copyparty.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.settings.copyparty.port} {
            header_up X-Forwarded-Proto "https" # needed behind cloudflare tunnel
          }
        '';
      };
    };
  };
}
