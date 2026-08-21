{...}: {
  flake.nixosModules.networkmanager = {config, ...}: {
    networking.networkmanager.enable = true;

    users.users.${config.settings.user.name}.extraGroups = [ "networkmanager" ];
  };
}
