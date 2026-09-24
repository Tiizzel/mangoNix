{
  flake.aspects.base.nixos = { ... }: {
    services.power-profiles-daemon.enable = true;
  };
}
