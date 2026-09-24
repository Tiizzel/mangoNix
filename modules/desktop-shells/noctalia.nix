{ inputs, pkgs, ... }: {
  flake.aspects.base.nixos = { pkgs, ... }: {
    imports = [
      inputs.noctalia.nixosModules.default
    ];

    programs.noctalia = {
      enable = true;
    };
  };
}
