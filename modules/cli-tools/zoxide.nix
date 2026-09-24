{
  flake.aspects.base.home = { pkgs, ... }: {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}
