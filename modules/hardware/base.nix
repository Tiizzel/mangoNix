{
  flake.aspects.base.nixos = { ... }: {
    imports = [ ../../hardware-configuration.nix ];
  };
}
