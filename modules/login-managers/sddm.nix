{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha-mauve";
      extraPackages = with pkgs.kdePackages; [
        qtsvg
        qtdeclarative
      ];
      settings = {
        Theme = {
          CursorTheme = "capitaine-cursors";
          CursorSize = 24;
        };
        General = {
          Numlock = "none";
        };
      };
    };

    environment.systemPackages = [
      (pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        accent = "mauve";
        font = "JetBrainsMono Nerd Font";
        fontSize = "11";
      })
      pkgs.capitaine-cursors
    ];

    security.pam.services.sddm.enableGnomeKeyring = true;
  };
}

