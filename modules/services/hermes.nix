{...}: {
  flake.nixosModules.hermes = {pkgs, lib, config, ...}: {
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

        container = {
          enable = true;
          backend = "podman";
          hostUsers = [ config.settings.user.name ];
        };

        environmentFiles = config.settings.hermes.env-files;

        # settings.model.default = "anthropic/claude-sonnet-4";
        extraDependencyGroups = [ "messaging" ];
      };
    };
  };
}
