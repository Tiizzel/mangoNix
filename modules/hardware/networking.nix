{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    networking.networkmanager.enable = true;
    environment.systemPackages = [
      pkgs.networkmanagerapplet
      pkgs.localsend
    ];
  };
}
