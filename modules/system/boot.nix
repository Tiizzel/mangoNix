{ inputs, ... }: {
  flake.aspects.base.nixos =
    { pkgs, lib, config, ... }:
    let
      distro-grub-theme = pkgs.stdenv.mkDerivation {
        pname = "distro-grub-themes-nixos";
        version = "3.2";
        src = pkgs.fetchFromGitHub {
          owner = "AdisonCavani";
          repo = "distro-grub-themes";
          rev = "v3.2";
          hash = "sha256-U5QfwXn4WyCXvv6A/CYv9IkR/uDx4xfdSgbXDl5bp9M=";
        };
        installPhase = ''
          mkdir -p $out
          tar -xf themes/nixos.tar -C $out
        '';
      };
    in
    {
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
      ];

      boot = {
        # Bootloader Configuration
        loader = {
          efi = {
            canTouchEfiVariables = true;
          };

          systemd-boot.enable = config.var.bootloader == "systemd-boot";

          grub = {
            enable = config.var.bootloader == "grub";
            efiSupport = true;
            device = "nodev";
            useOSProber = true;
            theme = distro-grub-theme;
            gfxmodeEfi = "auto";
            gfxmodeBios = "auto";
          };

          timeout = 5;
        };

        # Clean temporary files on startup
        tmp.cleanOnBoot = true;

        # Kernel configuration
        kernelPackages =
          if config.var.kernel == "cachyos-bore" then
            pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3
          else if config.var.kernel == "zen" then
            pkgs.linuxPackages_zen
          else if config.var.kernel == "latest" then
            pkgs.linuxPackages_latest
          else
            pkgs.linuxPackages;
      };
    };
}
