{
  flake.aspects.base.home = { pkgs, lib, ... }: {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        style = "full";
        theme = lib.mkForce "Dracula";
      };
      extraPackages = with pkgs.bat-extras; [
        batman
        batpipe
        batgrep
      ];
      };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
  };
}
