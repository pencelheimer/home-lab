{...}: {
  flake.nixosModules.kmscon = {pkgs, ...}: {
    fonts = {
      fontconfig.enable = true;
      packages = with pkgs; [
        nerd-fonts.iosevka-term
      ];
    };

    services.kmscon = {
      enable = true;

      config = {
	hwaccel = true;
        font-engine = "pango";
        font-name = "IosevkaTerm Nerd Font Mono";
        font-size = 16;
      };
    };
  };
}
