{
  flake.aspects.base.nixos = { config, ... }: {
    networking.hostName = config.var.hostname;
    networking.networkmanager.enable = true;
  };
}
