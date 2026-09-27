{ inputs, pkgs, ... }: {
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
