{
  flake.aspects.base.nixos = { ... }: {
    # Compressed in-memory swap device using zram
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
      memoryPercent = 100;
    };

    # Userspace out-of-memory daemon (systemd-oomd)
    systemd.oomd = {
      enable = true;
      enableUserSlices = true;
      enableSystemSlice = true;
      settings.OOM = {
        DefaultMemoryPressureDurationSec = 20;
      };
    };

    # Kernel virtual memory sysctl tuning for zram
    boot.kernel.sysctl = {
      # ZRAM performs best with high swappiness to compress cold pages and preserve file cache
      "vm.swappiness" = 180;
      # Disable multi-page read-ahead since zram has zero seek time (0 = 1 page at a time)
      "vm.page-cluster" = 0;
      # Avoid memory reclaim stalls during sudden allocation bursts
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };
  };
}
