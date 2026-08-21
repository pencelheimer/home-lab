{self, inputs, ...}: {
  flake.nixosConfigurations.home-lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      self.nixosModules.home-lab
    ];
  };

  flake.nixosModules.home-lab = {pkgs, ...}: {
    imports = [
      self.nixosModules.nix
      self.nixosModules.user
      self.nixosModules.locale
      self.nixosModules.networkmanager
      self.nixosModules.avahi

      self.nixosModules.ssh
      self.nixosModules.kmscon
      self.nixosModules.podman
      self.nixosModules.healthcheck-heartbeet

      self.nixosModules.apps
      self.nixosModules.fish

      self.nixosModules.cloudflared
      self.nixosModules.caddy
      self.nixosModules.postgresql
      self.nixosModules.vaultwarden
      self.nixosModules.miniflux
      self.nixosModules.rssbridge
      self.nixosModules.ntfy
      self.nixosModules.radicale
    ];

    settings.flake-path = "/home/pencelheimer/flake";
    settings.user.name = "pencelheimer";
    settings.user.initial-password = "12345";

    system.stateVersion = "26.05";

    networking.hostName = "home-lab";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
