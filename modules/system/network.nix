{
  flake.aspects.base.nixos = { ... }: {
    networking.hostName = "nixos";
    networking.networkmanager.enable = true;
  };
}
