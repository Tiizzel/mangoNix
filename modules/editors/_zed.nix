{
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.zed-editor
    ];
  };
}
