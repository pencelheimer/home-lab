{...}: {
  flake.nixosModules.nix = {config, lib, ...}: {
    imports = [];

    options = with lib.types; {
      settings.flake-path = lib.mkOption {
        type = str;
	description = "Path to the config flake dir.";
	default = "/opt/flake";
      };
    };

    config = {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      programs.nh = {
        enable = true;
        flake = config.settings.flake-path;
      };
    };
  };
}
