{...}: {
  flake.nixosModules.apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      wget
      curl
      yazi
      git-crypt
      cloudflared
      lm_sensors
    ];

    programs.neovim.enable = true;
    programs.neovim.defaultEditor = true;

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      clock24 = true;
    };

    # Rebuild service runs as root with no $HOME; it must trust the
    # pencelheimer-owned flake repo or git fails the ownership guard.
    # This writes to /etc/gitconfig (system-wide), read by all users.
    programs.git.enable = true;
    programs.git.config = {
      safe.directory = ["${config.settings.flake-path}"];
    };
  };
}
