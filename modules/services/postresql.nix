{...}: {
  flake.nixosModules.postgresql = {pkgs, ...}: {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_19;
    };
  };
}
