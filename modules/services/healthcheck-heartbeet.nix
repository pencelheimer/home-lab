{...}: {
  flake.nixosModules.healthcheck-heartbeat = {pkgs, lib, config, ...}: {
    options = with lib.types; {
      settings.healthcheck-heartbeat.id = lib.mkOption {
        type = str;
        description = "UUID of the endpoint to ping";
      };
    };

    config = {
      systemd.services.healthcheck-heartbeat = {
        description = "Ping Healthchecks.io";

        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
        };

        script = ''
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 https://hc-ping.com/${config.settings.healthcheck-heartbeat.id}
        '';
      };

      systemd.timers.healthcheck-heartbeat = {
        description = "Timer for Healthchecks.io heartbeat";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnBootSec = "3m";
          OnUnitActiveSec = "3m";
          Unit = "healthcheck-heartbeat.service";
        };
      };
    };
  };
       }
