{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    # GRAPHICS HARDWARE
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Critical for 32-bit games (Steam/Wine)
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ] ++ lib.optionals (config.var.gpu == "intel") [
        intel-media-driver
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    # Video Drivers selection
    services.xserver.videoDrivers = lib.mkDefault (
      if config.var.gpu == "nvidia" then [ "nvidia" ]
      else if config.var.gpu == "amd" then [ "amdgpu" ]
      else [ "modesetting" ]
    );

    # AMDGPU specific
    hardware.amdgpu = lib.mkIf (config.var.gpu == "amd") {
      opencl.enable = true;
      initrd.enable = true;
    };

    # NVIDIA specific
    hardware.nvidia = lib.mkIf (config.var.gpu == "nvidia") {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
    };

    # PERFORMANCE, LATENCY TUNING & HDR
    environment.variables = {
      MESA_SHADER_CACHE_MAX_SIZE = "4G";
      ENABLE_GAMESCOPE_WSI = "1";
      DXVK_HDR = "1";
      ENABLE_HDR_WSI = "1";
    } // (lib.optionalAttrs (config.var.gpu == "amd") {
      AMD_VULKAN_ICD = "RADV";
    });

    # AMDGPU CONTROLLER & OVERCLOCKING (LACT)
    services.lact.enable = lib.mkIf (config.var.gpu == "amd") true;

    boot.kernelParams = lib.mkIf (config.var.gpu == "amd") [
      "amdgpu.ppfeaturemask=0xffffffff"
      "amdgpu.freesync_video=1"
    ];

    environment.systemPackages = lib.mkIf (config.var.gpu == "amd") [
      pkgs.lact
    ];
  };
}
