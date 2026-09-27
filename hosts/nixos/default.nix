{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix
    ./variables.nix
  ];

  # Host-specific configuration and option overrides for 'nixos' can be placed here.
}
