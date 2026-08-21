{...}: {
  flake.nixosModules.podman = {pkgs, ...}: {
    imports = [];

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    virtualisation.oci-containers.backend = "podman";

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
