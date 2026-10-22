{...}: {
  flake.nixosModules.apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      wget
      curl
      yazi
      git-crypt
      cloudflared
      lm_sensors
      claude-code
    ];

    # Shared projects dir, accessible by the users group (like /srv/shared itself).
    systemd.tmpfiles.rules = [
      "d /srv/shared/projects 0770 root users -"
    ];

    programs.neovim.enable = true;
    programs.neovim.defaultEditor = true;

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      clock24 = true;
    };
  };
}
