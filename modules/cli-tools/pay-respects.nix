{
  flake.aspects.base.home = { pkgs, ... }: {
    programs.pay-respects = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
