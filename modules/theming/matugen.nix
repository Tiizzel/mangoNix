{
  flake.aspects.base.nixos = { pkgs, ... }: let
    matugen-apply = pkgs.writeShellScriptBin "matugen-apply" ''
      set -euo pipefail
      WALLPAPER="''${1:-$(${pkgs.noctalia}/bin/noctalia msg wallpaper-get 2>/dev/null || true)}"
      if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
        WALLPAPER="$HOME/Pictures/wallhaven-0w2xpq.jpg"
      fi

      if [ -f "$WALLPAPER" ]; then
        ${pkgs.matugen}/bin/matugen image "$WALLPAPER" --source-color-index 0
      else
        echo "No wallpaper found at $WALLPAPER" >&2
        exit 1
      fi
    '';
  in {
    environment.systemPackages = with pkgs; [
      matugen
      matugen-apply
    ];
  };
}
