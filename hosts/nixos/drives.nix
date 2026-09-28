{ config, ... }: {
  # Secondary NVMe Storage (Samsung SSD 970 EVO 1TB)
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/46ff86d6-01b4-4198-8a90-795151820f9c";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "nofail"
      "x-gvfs-show"
      "x-gvfs-name=Games"
    ];
  };

  # Ensure user ownership for /mnt/games
  systemd.tmpfiles.rules = [
    "d /mnt/games 0775 ${config.var.username} users -"
  ];
}
