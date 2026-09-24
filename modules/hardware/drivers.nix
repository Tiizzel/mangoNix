{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    # AMDGPU & GRAPHICS HARDWARE
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Critical for 32-bit games (Steam/Wine)
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    # Enable native AMD OpenCL and early KMS stage-1 loading
    hardware.amdgpu = {
      opencl.enable = true;
      initrd.enable = true;
    };

    # PERFORMANCE, LATENCY TUNING & HDR
    environment.variables = {
      # Enable a large shader cache size (forces Mesa to cache shaders to prevent in-game compilation stutter)
      MESA_SHADER_CACHE_MAX_SIZE = "4G";
      # Force Mesa RADV driver for optimal Vulkan gaming performance on RDNA3
      AMD_VULKAN_ICD = "RADV";
      # Enable HDR and Gamescope WSI extensions for Steam/Proton
      ENABLE_GAMESCOPE_WSI = "1";
      DXVK_HDR = "1";
      ENABLE_HDR_WSI = "1";
    };

    services.xserver.videoDrivers = ["amdgpu"];

    # AMDGPU CONTROLLER & OVERCLOCKING (LACT)
    # Enable LACT system daemon for fan curves, voltage control, and monitoring
    services.lact = {
      enable = true;
    };

    # Required featuremask kernel parameter to unlock overdrive power states in LACT and enable FreeSync video
    boot.kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
      "amdgpu.freesync_video=1"
    ];

    # Install LACT GUI and CLI utilities for control
    environment.systemPackages = with pkgs; [
      lact
    ];
  };
}
