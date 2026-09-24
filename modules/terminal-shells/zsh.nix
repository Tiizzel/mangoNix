{
  flake.aspects.base.nixos = { pkgs, config, ... }: {
    programs.zsh = {
      enable = true;
      interactiveShellInit = ''
        # Custom fc function for cleaning nix generations
        fc() {
          if [[ "$*" == *"-h"* ]] || [[ "$*" == *"--help"* ]]; then
            nh clean all --help
            return 0
          fi

          local keep=""
          local args=()

          while [[ $# -gt 0 ]]; do
            if [[ "$1" =~ ^[0-9]+''$ ]]; then
              keep="$1"
            else
              args+=("$1")
            fi
            shift
          done

          if [ -z "$keep" ]; then
            echo -n "How many generations to keep? [5]: "
            read -r keep
            keep="''${keep:-5}"
          fi

          if [[ ! "$keep" =~ ^[0-9]+''$ ]]; then
            echo "Error: Keep count must be a number."
            return 1
          fi

          nh clean all --keep "$keep" "''${args[@]}"
        }
      '';
    };
    environment.shellAliases = {
      sv = "sudo nvim";
      v = "nvim";
      c = "clear";
      fr = "nh os switch ${config.var.dotfilesDir}";
      fu = "nh os switch --update ${config.var.dotfilesDir}";
    };
    environment.systemPackages = [
      pkgs.oh-my-posh
    ];
    users.users.${config.var.username}.shell = pkgs.zsh;
    users.defaultUserShell = pkgs.zsh;
  };

  flake.aspects.base.home = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "web-search"
          "copyfile"
          "copybuffer"
          "dirhistory"
        ];
      };
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
          file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        }
      ];
      initContent = ''
        # Load dotfiles zshrc fragments
        if [[ -d ~/.config/zshrc ]]; then
            for f in ~/.config/zshrc/*(N); do
                [[ -d "$f" ]] && continue
                c="$(echo $f | sed -e 's=.config/zshrc=.config/zshrc/custom=')"
                [[ -f "$c" ]] && source "$c" || source "$f"
            done
        fi
      '';
    };
    programs.fzf.enable = true;
  };
}
