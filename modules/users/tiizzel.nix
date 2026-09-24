{
  flake.aspects.base.nixos = { pkgs, ... }: {
    users.users."tiizzel" = {
      isNormalUser = true;
      description = "Tiizzel";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.tiizzel = { pkgs, ... }: {
        home.stateVersion = "24.05";
        programs.home-manager.enable = true;
      };
    };
  };
}
