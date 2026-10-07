{inputs, ...}: {
  flake.nixosModules.hermes = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options = {
      settings.hermes = with lib.types; {
        env-files = lib.mkOption {
          type = listOf path;
          description = "List of environemnt files accessed by the agent";
        };
      };
    };

    config = {
      services.hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        environmentFiles = config.settings.hermes.env-files;
        extraPackages = with pkgs; [playwright-mcp];

        settings.model = {
          provider = "openrouter";
          # -0731 pinned snapshot: $0.08/$0.18 per M vs $0.14/$0.28 on the rolling
          # id (checked 2026-08-13), same 1M context
          default = "deepseek/deepseek-v4-flash-0731";
        };

        settings.auxiliary.vision = {
          provider = "openrouter";
          model = "qwen/qwen3.5-flash-02-23";
        };

        settings.display = {
          show_reasoning = true;
          show_cost = true;
          streaming = true;
          tool_progress = "verbose";
          platforms.telegram = {
            tool_progress = "verbose";
            tool_preview_length = 1000;
          };
        };

        settings.platforms.telegram.enabled = true;

        mcpServers.playwright = {
          command = "playwright-mcp";
          args = ["--headless" "--isolated"];
          timeout = 180;
        };
      };

      environment.shellAliases.hermes-as = "sudo -u hermes -H env HERMES_HOME=/var/lib/hermes/.hermes hermes";

      systemd.services.hermes-agent.serviceConfig.SupplementaryGroups = ["systemd-journal"];
      systemd.services.hermes-agent.serviceConfig.NoNewPrivileges = lib.mkForce false;
      security.sudo.execWheelOnly = lib.mkForce false;
      security.sudo.extraRules = [
        {
          users = ["hermes"];
          commands = [
            {
              command = "/etc/hermes-rebuild.sh";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
      environment.etc."hermes-rebuild.sh" = {
        mode = "0555";
        text = ''
          #!/bin/sh
          # Trigger the rebuild as a dedicated, sandbox-unrestricted systemd unit.
          # hermes-agent runs with ProtectSystem=strict, which makes /nix and /boot
          # read-only even for a root child in this namespace - so the actual
          # nixos-rebuild must run OUTSIDE that mount namespace. Block until done.
          set -e
          exec systemctl start --wait hermes-rebuild.service
        '';
      };
      # The rebuild itself runs here: one-shot, root, unrestricted namespace,
      # so it can update /nix/var/nix/profiles, the nix store and the GRUB bootloader.
      # hermes-agent's own ProtectSystem sandbox stays fully intact.
      systemd.services.hermes-rebuild = {
        description = "rebuild+switch the NixOS configuration";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        serviceConfig = {Type = "oneshot";};
        script = ''
          /run/current-system/sw/bin/nixos-rebuild switch --cores 0 --max-jobs auto \
            --flake ${config.settings.flake-path}
        '';
      };

      # Upstream packaging bug: pyproject.toml [tool.setuptools] py-modules
      # omits registration_lifecycle, so it never lands in the sealed venv
      # and hermes_cli/plugins.py:62 `from registration_lifecycle import ...`
      # raises ModuleNotFoundError -> `hermes gateway` dies during startup,
      # every time. Shipping the one missing file on PYTHONPATH is enough;
      # the venv itself is fine. NOTE: this has to be a real systemd
      # Environment= - the module's own `environment` option only merges into
      # $HERMES_HOME/.env, which Hermes loads from inside Python, far too
      # late to affect sys.path. Drop this once upstream py-modules lists the
      # module.
      systemd.services.hermes-agent.environment.PYTHONPATH = pkgs.runCommand "hermes-registration-lifecycle" {} ''
        mkdir -p $out
        cp ${inputs.hermes-agent}/registration_lifecycle.py $out/
      '';
    };
  };
}
