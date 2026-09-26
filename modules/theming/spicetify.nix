{ inputs, ... }: {
  flake.aspects.base.nixos = { config, pkgs, ... }: let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    spicedSpotify = config.programs.spicetify.spicedSpotify;
    spicetifyCli = "${pkgs.spicetify-cli}/bin/spicetify";
  in {
    imports = [
      inputs.spicetify-nix.nixosModules.default
    ];

    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.comfy;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
      ];
    };

    environment.systemPackages = [
      pkgs.spicetify-cli
    ];

    system.userActivationScripts.syncSpicetify = {
      text = ''
        SPOTIFY_SRC="${spicedSpotify}/share/spotify"
        TARGET_DIR="$HOME/.local/share/spotify"
        STAMP_FILE="$TARGET_DIR/.nix_source_version"

        if [ ! -f "$STAMP_FILE" ] || [ "$(cat "$STAMP_FILE" 2>/dev/null)" != "$SPOTIFY_SRC" ]; then
          echo "Syncing updated Spotify to $TARGET_DIR..."
          rm -rf "$TARGET_DIR"
          mkdir -p "$TARGET_DIR"
          cp -rL "$SPOTIFY_SRC"/* "$TARGET_DIR/"
          cp -L "$SPOTIFY_SRC"/.* "$TARGET_DIR/" 2>/dev/null || true
          chmod -R u+w "$TARGET_DIR"
          ${pkgs.gnused}/bin/sed "s|$SPOTIFY_SRC/.spotify-wrapped|$TARGET_DIR/.spotify-wrapped|g" "${spicedSpotify}/bin/spotify" > "$TARGET_DIR/spotify-run"
          chmod +x "$TARGET_DIR/spotify-run"
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
      '';
    };
  };
}
