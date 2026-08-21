{self, inputs, ...}: {
  flake.nixosConfigurations.home-lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      self.nixosModules.home-lab
    ];
  };

  flake.nixosModules.home-lab = {pkgs, ...}: {
    imports = [
    ];

    system.stateVersion = "26.05";

    networking.hostName = "home-lab";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
