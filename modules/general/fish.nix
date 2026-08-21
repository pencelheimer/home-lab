{...}: {
  flake.nixosModules.fish = {pkgs, config, ...}: {
    programs.fish.enable = true;

    users.users.${config.settings.user.name} = {
      shell = pkgs.fish;
    };
  };
}
