{ inputs, ... }: {
  flake.aspects.base.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      spicedSpotify = config.programs.spicetify.spicedSpotify;
      spicetifyCli = "${pkgs.spicetify-cli}/bin/spicetify";

      # Script that re-applies Spicetify theme files and reloads the Spotify CEF interface live
      spotifyReloadCef = pkgs.writeShellScriptBin "spotify-reload-cef" ''
        set -euo pipefail
        LOCKFILE="/tmp/.spotify-reload-cef.lock"
        NOW=$(${pkgs.coreutils}/bin/date +%s)
        if [ -f "$LOCKFILE" ]; then
          LAST_TIME=$(cat "$LOCKFILE" 2>/dev/null || echo 0)
          if [ "$((NOW - LAST_TIME))" -lt 1 ]; then
            exit 0
          fi
        fi
        echo "$NOW" > "$LOCKFILE" 2>/dev/null || true

        ${spicetifyCli} -q apply --no-restart 2>/dev/null || true

        if ${pkgs.curl}/bin/curl -s --connect-timeout 1 http://127.0.0.1:9222/json/list >/dev/null 2>&1; then
          for ws in $(${pkgs.curl}/bin/curl -s http://127.0.0.1:9222/json/list | ${pkgs.jq}/bin/jq -r '.[] | select(.type == "page") | .webSocketDebuggerUrl // empty'); do
            if [ -n "$ws" ]; then
              echo '{"id":1,"method":"Page.reload"}' | ${pkgs.websocat}/bin/websocat -n1 "$ws" >/dev/null 2>&1 || true
            fi
          done
        fi
      '';

      # Wrapper script that prioritizes the locally patched Spotify instance (with Noctalia wallpaper colors)
      # over the read-only Nix store Spotify instance, ensuring remote debugging is enabled for CEF hot-reloading.
      spotifyWrapper = pkgs.writeShellScriptBin "spotify" ''
        if [ -x "$HOME/.local/share/spotify/spotify-run" ]; then
          exec "$HOME/.local/share/spotify/spotify-run" "$@"
        else
          exec "${spicedSpotify}/bin/spotify" --remote-debugging-port=9222 "$@"
        fi
      '';
    in
    {
      imports = [
        inputs.spicetify-nix.nixosModules.default
      ];

      environment.localBinInPath = true;

      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.comfy;
        enabledExtensions = with spicePkgs.extensions; [
          adblock
        ];
      };

      environment.systemPackages = [
        (lib.hiPrio spotifyWrapper)
        spotifyReloadCef
        pkgs.websocat
        pkgs.spicetify-cli
      ];

      system.userActivationScripts.syncSpicetify = {
        text = ''
          SPOTIFY_SRC="${spicedSpotify}/share/spotify"
          TARGET_DIR="$HOME/.local/share/spotify"
          STAMP_FILE="$TARGET_DIR/.nix_source_version"

          if [ ! -f "$STAMP_FILE" ] || [ "$(cat "$STAMP_FILE" 2>/dev/null)" != "$SPOTIFY_SRC" ] || [ ! -f "$TARGET_DIR/spotify-run" ]; then
            echo "Syncing updated Spotify to $TARGET_DIR..."
            rm -rf "$TARGET_DIR"
            mkdir -p "$TARGET_DIR"
            cp -rL "$SPOTIFY_SRC"/* "$TARGET_DIR/"
            cp -L "$SPOTIFY_SRC"/.* "$TARGET_DIR/" 2>/dev/null || true
            chmod -R u+w "$TARGET_DIR"
            ${pkgs.gnused}/bin/sed "s|\"$SPOTIFY_SRC/.spotify-wrapped\"|\"$TARGET_DIR/.spotify-wrapped\" --remote-debugging-port=9222|g" "${spicedSpotify}/bin/spotify" > "$TARGET_DIR/spotify-run"
            chmod +x "$TARGET_DIR/spotify-run"
            cp -f "$TARGET_DIR/spotify-run" "$TARGET_DIR/spotify"
            echo "$SPOTIFY_SRC" > "$STAMP_FILE"

            mkdir -p "$HOME/.local/bin"
            ln -sf "$TARGET_DIR/spotify-run" "$HOME/.local/bin/spotify"

            mkdir -p "$HOME/.local/share/applications"
            cat << 'EOF' > "$HOME/.local/share/applications/spotify.desktop"
[Desktop Entry]
Type=Application
Name=Spotify
GenericName=Music Player
Icon=spotify-client
TryExec=spotify
Exec=spotify %U
Terminal=false
MimeType=x-scheme-handler/spotify;
Categories=Audio;Music;Player;AudioVideo;
StartupWMClass=spotify
EOF

            ${spicetifyCli} config spotify_path "$TARGET_DIR" 2>/dev/null || true
            ${spicetifyCli} -q apply --no-restart 2>/dev/null || true
          fi

          # Ensure Noctalia community template apply.sh invokes the CEF reload script
          APPLY_SH="$HOME/.local/state/noctalia/community-templates/spicetify/apply.sh"
          if [ -d "$HOME/.local/state/noctalia/community-templates/spicetify" ]; then
            cat << 'APPLY_EOF' > "$APPLY_SH"
#!/usr/bin/env bash
set -euo pipefail

if command -v spotify-reload-cef >/dev/null 2>&1; then
  spotify-reload-cef || true
elif [ -x "$HOME/.local/bin/spotify-reload-cef" ]; then
  "$HOME/.local/bin/spotify-reload-cef" || true
else
  spicetify -q apply --no-restart 2>/dev/null || true
fi
APPLY_EOF
            chmod +x "$APPLY_SH"
          fi
        '';
      };
    };
}
