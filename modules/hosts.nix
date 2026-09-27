{ inputs, ... }: let
  hostsDir = ../hosts;

  # Discover all subdirectories in ../hosts that contain a default.nix
  hostDirs = if builtins.pathExists hostsDir then
    inputs.nixpkgs.lib.filterAttrs (name: type:
      type == "directory" && builtins.pathExists (hostsDir + "/${name}/default.nix")
    ) (builtins.readDir hostsDir)
  else {};

  mkHost = hostName: hostPath: inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.self.modules.nixos.base
      hostPath
      ({ lib, ... }: {
        networking.hostName = lib.mkDefault hostName;
      })
    ];
  };

  # Map discovered directories into nixosConfigurations
  discoveredConfigurations = inputs.nixpkgs.lib.mapAttrs (name: _: mkHost name (hostsDir + "/${name}")) hostDirs;
in {
  flake.nixosConfigurations = discoveredConfigurations;
}
