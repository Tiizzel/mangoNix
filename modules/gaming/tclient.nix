{
  flake.aspects.base.nixos = { ... }: {
    security.pki.certificates = [
      (builtins.readFile ./certs/cert.pem)
    ];
  };

  flake.aspects.base.home = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      taterclient-ddnet
    ];

    # Desktop entry so it shows up in your App Launcher
    xdg.desktopEntries.tclient = {
      name = "TaterClient";
      genericName = "Teeworlds / DDNet Client";
      exec = "systemd-cat -t tclient TaterClient-DDNet";
      icon = "ddnet";
      categories = [ "Game" ];
      terminal = false;
    };

    # Writable symlink for DDNet configuration
    home.file.".local/share/ddnet".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ddnet-data";

    # Local LibreTranslate service for in-game chat translation without rate limits
    systemd.user.services.libretranslate = {
      Unit = {
        Description = "LibreTranslate translation service for TaterClient";
      };
      Service = {
        ExecStart = "${pkgs.libretranslate}/bin/libretranslate --host 127.0.0.1 --port 5000 --load-only en,de,ru,zh,fr,es,pl,uk,tr --disable-web-ui";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # HTTPS proxy to fulfill TaterClient's HTTPS requirement & filter German messages
    systemd.user.services.tclient-proxy = {
      Unit = {
        Description = "TaterClient Translation HTTPS Filter Proxy";
        After = [ "libretranslate.service" ];
        Requires = [ "libretranslate.service" ];
      };
      Service = {
        ExecStart = "${pkgs.python3}/bin/python3 ${config.home.homeDirectory}/mangoNix/modules/gaming/tclient-proxy.py";
        Environment = [
          "PROXY_CERT=${config.home.homeDirectory}/mangoNix/modules/gaming/certs/cert.pem"
          "PROXY_KEY=${config.home.homeDirectory}/mangoNix/modules/gaming/certs/key.pem"
          "PROXY_PORT=5001"
        ];
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
