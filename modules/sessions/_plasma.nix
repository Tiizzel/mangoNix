{
  flake.aspects.base.nixos = { ... }: {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };
  };
}
