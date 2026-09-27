{ config, ... }: {
  # Secondary NVMe Storage (Samsung SSD 970 EVO 1TB)
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/1e241d1b-54b4-4ad7-8104-8490543cb3db";
    fsType = "ext4";
    options = [ "defaults" "noatime" ];
  };

  # Ensure user ownership for /mnt/games
  systemd.tmpfiles.rules = [
    "d /mnt/games 0775 ${config.var.username} users -"
  ];
}
