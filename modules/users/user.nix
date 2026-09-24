{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    options.var = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "tiizzel";
        description = "Primary user account name";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Tiizzel";
        description = "Primary user's real or display name";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "System hostname";
      };
      dotfilesDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.var.username}/mangoNix";
        description = "Path to the mangoNix configuration directory";
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Berlin";
        description = "System timezone";
      };
      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "de";
        description = "System keyboard layout";
      };
      gpu = lib.mkOption {
        type = lib.types.enum [ "amd" "nvidia" "intel" "vm" "generic" ];
        default = "amd";
        description = "Primary GPU driver profile";
      };
    };

    config = {
      users.users.${config.var.username} = {
        isNormalUser = true;
        description = config.var.name;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
          kdePackages.kate
        ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.${config.var.username} = { pkgs, ... }: {
          home.stateVersion = "24.05";
          programs.home-manager.enable = true;
          imports = [
            inputs.self.modules.home.base
          ];
        };
      };
    };
  };
}
