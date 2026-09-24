{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "chili";
      extraPackages = with pkgs; [
        sddm-chili-theme
        kdePackages.qt5compat
        kdePackages.qtdeclarative
        kdePackages.qtsvg
        kdePackages.qtmultimedia
        kdePackages.qtvirtualkeyboard
      ];
    };

    environment.systemPackages = [
      pkgs.sddm-chili-theme
    ];
  };
}
