{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, ... }: {
    imports = [
      inputs.spicetify-nix.nixosModules.default
    ];

    programs.spicetify = {
      enable = true;
      enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.extensions; [
        adblock
      ];
    };

    environment.systemPackages = [
      pkgs.spicetify-cli
    ];
  };
}
