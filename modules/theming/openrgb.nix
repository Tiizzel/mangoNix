{
  flake.aspects.base.nixos = { pkgs, ... }: let
    openrgb-wooting-sync = pkgs.writeShellScriptBin "openrgb-wooting-sync" ''
      SCRIPT="$HOME/mangoNix/dotfiles/openrgb/apply-wooting-theme.sh"
      if [ -f "$SCRIPT" ]; then
        exec bash "$SCRIPT" "$@"
      else
        echo "apply-wooting-theme.sh not found at $SCRIPT" >&2
        exit 1
      fi
    '';
  in {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = "amd";
    };

    environment.systemPackages = with pkgs; [
      openrgb-with-all-plugins
      openrgb-wooting-sync
      inotify-tools
    ];
  };
}
