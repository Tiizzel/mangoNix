{ inputs, ... }: {
  flake.aspects.base.nixos =
    { pkgs, lib, ... }:
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
        # Bootloader Configuration (GRUB with Distro Theme)
        loader = {
          systemd-boot.enable = false;

          efi = {
            canTouchEfiVariables = true;
          };

          grub = {
            enable = true;
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
        # CachyOS with BORE (Burst-Oriented Response Enhancer) scheduler
        # Compiled with Clang LTO optimized for x86_64-v3 (AMD Zen 3 / Ryzen 5000 series)
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
      };
    };
}
