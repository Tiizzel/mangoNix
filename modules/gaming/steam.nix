{
  flake.aspects.base.nixos = { pkgs, config, ... }: {
    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraProfile = ''
            export MILLENNIUM_RUNTIME_PATH="/home/${config.var.username}/.local/share/millennium/libmillennium_x86.so"
            mkdir -p "/home/${config.var.username}/.steam/steam/ubuntu12_32" "/home/${config.var.username}/.steam/steam/ubuntu12_64" "/home/${config.var.username}/.steam/steam/millennium"
            ln -sf "/home/${config.var.username}/.local/share/millennium/libmillennium_bootstrap_x86.so" "/home/${config.var.username}/.steam/steam/ubuntu12_32/libXtst.so.6"
            ln -sf "/home/${config.var.username}/.local/share/millennium/libmillennium_bootstrap_hhx64.so" "/home/${config.var.username}/.steam/steam/ubuntu12_64/libXtst.so.6"
            ln -sf "/home/${config.var.username}/.local/share/millennium/libmillennium_hhx64.so" "/home/${config.var.username}/.steam/steam/ubuntu12_64/libmillennium_hhx64.so"
            if [ -d "/home/${config.var.username}/.steam/steam/steamui/skins" ]; then
              ln -sfn "/home/${config.var.username}/.steam/steam/steamui/skins" "/home/${config.var.username}/.steam/steam/millennium/themes"
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
