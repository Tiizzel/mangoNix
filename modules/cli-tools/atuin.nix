{
  flake.aspects.base.home = { pkgs, ... }: {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        search_mode = "fuzzy";
      };
    };
  };
}
