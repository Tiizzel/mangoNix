{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    hardware.wooting.enable = true;

    environment.systemPackages = with pkgs; [
      wootility
    ];
  };
}
