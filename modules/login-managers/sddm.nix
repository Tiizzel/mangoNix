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
            # Invisible-cursor fix (greeter side): the greeter can't find cursor
            # themes because NixOS has no /usr/share/icons, and XCURSOR_PATH is only
            # set for login shells (/etc/set-environment), not for the SDDM service.
            # Point it at the system profile so Bibata-Modern-Ice can load.
            GreeterEnvironment = "XCURSOR_PATH=/run/current-system/sw/share/icons";
          };
        };
      };

      # Invisible-cursor fix (compositor side): SDDM's Wayland greeter runs inside
      # Weston, which inherits the display-manager service environment. Give it the
      # same cursor search path, theme and size so it can draw a cursor too.
      systemd.services.display-manager.environment = {
        XCURSOR_PATH = "/run/current-system/sw/share/icons";
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
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
