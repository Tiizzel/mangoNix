{ inputs, pkgs, ... }: {
  flake.aspects.base.nixos = { pkgs, ... }: {
    imports = [ inputs.mangowm.nixosModules.mango ];

    programs.mango.enable = true;

    security.polkit.enable = true;

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    environment.systemPackages = [ pkgs.polkit_gnome ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      SDL_VIDEODRIVER = "wayland,x11";
    };
  };

  flake.aspects.base.home = { config, lib, osConfig, ... }: let
    relDotfiles = lib.removePrefix "${config.home.homeDirectory}/" osConfig.var.dotfilesDir;
  in {
    home.file."${relDotfiles}/dotfiles/mango/cfg/mango-monitors.conf".text = ''
      # Auto-generated monitor rules for host: ${osConfig.var.hostname}
      ${lib.concatMapStringsSep "\n" (rule: "monitorrule = ${rule}") osConfig.var.monitorRules}
    '';
  };
}
