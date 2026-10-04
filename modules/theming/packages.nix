{
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      bibata-cursors
      bibata-caelestia
      bibata-cursors-translucent
      lxappearance
      nwg-look
    ];
  };
}
