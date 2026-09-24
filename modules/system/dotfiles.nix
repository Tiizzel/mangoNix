{ inputs, pkgs, ... }: {
  flake.aspects.base.home = { config, ... }: let
    link = config.lib.file.mkOutOfStoreSymlink;
    dotDir = "${config.home.homeDirectory}/mangoNix/dotfiles";
  in {
    home.file = {
      ".config/antigravity-ide".source = link "${dotDir}/antigravity-ide";
      ".config/Antigravity/User/settings.json".source = link "${dotDir}/antigravity-ide/settings.json";
      ".config/Antigravity/User/keybindings.json".source = link "${dotDir}/antigravity-ide/keybindings.json";
      ".config/btop".source = link "${dotDir}/btop";
      ".config/fastfetch".source = link "${dotDir}/fastfetch";
      ".config/ghostty".source = link "${dotDir}/ghostty";
      ".config/gtk-3.0".source = link "${dotDir}/gtk-3.0";
      ".config/gtk-4.0".source = link "${dotDir}/gtk-4.0";
      ".config/kitty".source = link "${dotDir}/kitty";
      ".config/mango".source = link "${dotDir}/mango";
      ".config/matugen".source = link "${dotDir}/matugen";
      ".config/noctalia".source = link "${dotDir}/noctalia";
      ".config/ohmyposh".source = link "${dotDir}/ohmyposh";
      ".config/sddm".source = link "${dotDir}/sddm";
      ".config/Thunar".source = link "${dotDir}/thunar";
      ".config/thunar".source = link "${dotDir}/thunar";
      ".config/yazi".source = link "${dotDir}/yazi";
      ".config/zen-browser".source = link "${dotDir}/zen-browser";
      ".config/zen".source = link "${dotDir}/zen-browser";
      ".config/zshrc".source = link "${dotDir}/zshrc";
      ".local/state/noctalia/settings.toml".source = link "${dotDir}/noctalia/settings.toml";
    };
  };
}
