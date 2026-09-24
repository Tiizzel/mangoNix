{
  flake.aspects.base.home = { pkgs, ... }: {
    programs.fzf = {
      enable = true;
      historyWidget.command = "";
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      defaultOptions = [
        "--margin=1"
        "--layout=reverse"
        "--border=none"
        "--info='inline'"
        "--header=''"
        "--prompt='/ '"
        "-i"
        "--no-bold"
        "--bind='enter:execute(nvim {})'"
        "--preview='bat --style=numbers --color=always --line-range :500 {}'"
        "--preview-window=right:60%:wrap"
      ];
    };
  };
}
