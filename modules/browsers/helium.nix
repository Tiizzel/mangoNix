{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
