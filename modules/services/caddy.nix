{...}: {
  flake.nixosModules.caddy = {pkgs, ...}: {
    services.caddy = {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
    };
  };
}
