{
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      antigravity-ide
    ];
  };
}
