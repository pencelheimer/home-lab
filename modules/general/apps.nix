{...}: {
  flake.nixosModules.apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      git
      wget
      curl
      yazi
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
