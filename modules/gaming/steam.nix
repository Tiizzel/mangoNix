{
  flake.aspects.base.nixos = { pkgs, config, ... }: {
    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraProfile = ''
            MILLENNIUM_DIR="/home/${config.var.username}/.local/share/millennium"
            STEAM_DIR="/home/${config.var.username}/.local/share/Steam"

            if [ -f "$MILLENNIUM_DIR/libmillennium_bootstrap_x86.so" ]; then
              export MILLENNIUM_RUNTIME_PATH="$MILLENNIUM_DIR/libmillennium_x86.so"
              mkdir -p "$STEAM_DIR/ubuntu12_32" "$STEAM_DIR/ubuntu12_64" "$STEAM_DIR/millennium"
              ln -sf "$MILLENNIUM_DIR/libmillennium_bootstrap_x86.so" "$STEAM_DIR/ubuntu12_32/libXtst.so.6"
              ln -sf "$MILLENNIUM_DIR/libmillennium_bootstrap_hhx64.so" "$STEAM_DIR/ubuntu12_64/libXtst.so.6"
              ln -sf "$MILLENNIUM_DIR/libmillennium_hhx64.so" "$STEAM_DIR/ubuntu12_64/libmillennium_hhx64.so"
              if [ -d "$STEAM_DIR/steamui/skins" ]; then
                ln -sfn "$STEAM_DIR/steamui/skins" "$STEAM_DIR/millennium/themes"
              fi
            else
              [ -L "$STEAM_DIR/ubuntu12_32/libXtst.so.6" ] && [ ! -e "$STEAM_DIR/ubuntu12_32/libXtst.so.6" ] && rm -f "$STEAM_DIR/ubuntu12_32/libXtst.so.6"
              [ -L "$STEAM_DIR/ubuntu12_64/libXtst.so.6" ] && [ ! -e "$STEAM_DIR/ubuntu12_64/libXtst.so.6" ] && rm -f "$STEAM_DIR/ubuntu12_64/libXtst.so.6"
            fi
          '';
        };
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = false;
        gamescopeSession.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      gamescope = {
        enable = true;
        capSysNice = false; # TODO: re-enable once nixpkgs fixes bubblewrap setuid regression (#523200)
        args = [
          "--rt"
          "--expose-wayland"
        ];
      };
    };

    environment.sessionVariables = {
      MILLENNIUM_RUNTIME_PATH = "/home/${config.var.username}/.local/share/millennium/libmillennium_x86.so";
    };
  };
}
