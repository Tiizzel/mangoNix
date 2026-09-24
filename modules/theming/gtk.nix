{ pkgs, ... }: {
  flake.aspects.base.nixos = { ... }: {
    programs.dconf.enable = true;
  };

  flake.aspects.base.home = { pkgs, ... }: {
    home.packages = with pkgs; [
      adw-gtk3
      papirus-icon-theme
      papirus-folders
    ];

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
        icon-theme = "Papirus-Dark";
      };
    };
  };
}
