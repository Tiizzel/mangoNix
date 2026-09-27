{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix
    ./variables.nix
    ./drives.nix
  ];
}
