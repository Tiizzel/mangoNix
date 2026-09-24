{
  flake.aspects.base.nixos = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
      ];
    };

    programs.xfconf.enable = true;

    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      ntfs3g
      file-roller
    ];
  };
}
