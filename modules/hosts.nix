{ inputs, ... }: {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.self.modules.nixos.base
      {
        home-manager.users.tiizzel.imports = [
          inputs.self.modules.home.base
        ];
      }
    ];
  };
}
