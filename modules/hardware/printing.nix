{
  flake.aspects.base.nixos = { ... }: {
    services.printing.enable = true;
  };
}
