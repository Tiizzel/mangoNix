{ inputs, ... }: {
  flake.aspects.base.nixos =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = [ pkgs.bibata-cursors ] ++ (with pkgs.kdePackages; [
          qtsvg
          qtdeclarative
          qtmultimedia
          qtvirtualkeyboard
        ]);
        settings = {
          Theme = {
            CursorTheme = "Bibata-Modern-Ice";
            CursorSize = 24;
          };
          General = {
            Numlock = "none";
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/cache/sddm-theme 0775 ${config.var.username} sddm -"
      ];

      environment.systemPackages = [
        (
          (pkgs.sddm-astronaut.override {
            embeddedTheme = "purple_leaves";
          }).overrideAttrs
            (old: {
              postInstall = (old.postInstall or "") + ''
                chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Themes
                ln -sf /var/cache/sddm-theme/purple_leaves.conf.user \
                  $out/share/sddm/themes/sddm-astronaut-theme/Themes/purple_leaves.conf.user
              '';
            })
        )
        pkgs.bibata-cursors
      ];

      security.pam.services.sddm.enableGnomeKeyring = true;
    };
}
