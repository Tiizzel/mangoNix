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
      enableSops = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SOPS encrypted secrets management";
      };
      gitUsername = lib.mkOption {
        type = lib.types.str;
        default = config.var.name;
        description = "Default Git user name";
      };
      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "adamdominik1996@gmail.com";
        description = "Default Git user email address";
      };
      kernel = lib.mkOption {
        type = lib.types.enum [ "cachyos-bore" "zen" "latest" "default" ];
        default = "cachyos-bore";
        description = "Linux kernel package variant to use";
      };
      bootloader = lib.mkOption {
        type = lib.types.enum [ "grub" "systemd-boot" ];
        default = "grub";
        description = "Bootloader to install and configure";
      };
      monitorRules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "name:DP-1, width:5120, height:1440, refresh:240, x:0, y:0, rr:0, vrr:0, hdr:1, hdr_force:1, hdr_min_lum: 0.05, hdr_max_lum: 800"
        ];
        description = "List of MangoWM monitorrule configuration strings";
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
