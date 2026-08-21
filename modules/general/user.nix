{...}: {
  flake.nixosModules.user = {lib, config, ...}: {
    options = with lib.types; {
      settings.user.name = lib.mkOption {
        type = str;
	default = "pencelheimer";
      };

      settings.user.initial-password = lib.mkOption {
        type = str;
	default = "12345";
      };
    };

    config = {
      users.users.${config.settings.user.name} = {
        isNormalUser = true;
        description = "${config.settings.user.name}";
        initialPassword = "${config.settings.user.initial-password}";
        extraGroups = [ "wheel" ];
      };
    };
  };
}
