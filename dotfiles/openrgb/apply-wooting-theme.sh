#!/usr/bin/env bash
# Noctalia / Matugen Theme Sync for Wooting 80HE & Motherboard via OpenRGB

KITTY_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/themes/noctalia.conf"
MANGO_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/mango/noctalia.conf"
SETTINGS_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/settings.toml"
YAZI_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/yazi/flavors/noctalia.yazi/flavor.toml"
MATUGEN_JSON="$HOME/mangoNix/dotfiles/matugen/colors.json"

apply_theme() {
  # Default Matugen values rendered from current wallpaper
  PRIMARY="afd18c"
  SECONDARY="bfcbae"
  ON_PRIMARY="1d3703"
  ON_SECONDARY="29341f"

  # If Noctalia config is active, prefer Noctalia's exact active palette
  if [ -f "$KITTY_CONF" ]; then
    p=$(grep -E "^active_border_color" "$KITTY_CONF" | awk '{print $2}' | tr -d '#' | tr '[:upper:]' '[:lower:]' || true)
    s=$(grep -E "^color3" "$KITTY_CONF" | awk '{print $2}' | tr -d '#' | tr '[:upper:]' '[:lower:]' || true)
    on_p=$(grep -E "^active_tab_foreground" "$KITTY_CONF" | awk '{print $2}' | tr -d '#' | tr '[:upper:]' '[:lower:]' || true)

    [ -n "$p" ] && PRIMARY="$p"
    [ -n "$s" ] && SECONDARY="$s"
    [ -n "$on_p" ] && ON_PRIMARY="$on_p"
  elif [ -f "$MANGO_CONF" ]; then
    p=$(grep -E "^focuscolor" "$MANGO_CONF" | head -n 1 | awk '{print $3}' | sed 's/^0x//; s/..$//' | tr '[:upper:]' '[:lower:]' || true)
    s=$(grep -E "^maximizescreencolor" "$MANGO_CONF" | head -n 1 | awk '{print $3}' | sed 's/^0x//; s/..$//' | tr '[:upper:]' '[:lower:]' || true)
    on_p=$(grep -E "^jump_label_decorate_focus_fg_color" "$MANGO_CONF" | head -n 1 | awk '{print $3}' | sed 's/^0x//; s/..$//' | tr '[:upper:]' '[:lower:]' || true)

    [ -n "$p" ] && PRIMARY="$p"
    [ -n "$s" ] && SECONDARY="$s"
    [ -n "$on_p" ] && ON_PRIMARY="$on_p"
  fi

  WP_NAME=$(basename "$(noctalia msg wallpaper-get 2>/dev/null || true)" | cut -d. -f1)
  PALETTE_FILE=$(ls ~/.config/noctalia/palettes/"$WP_NAME"*.json 2>/dev/null | head -n 1)
  if [ -n "$PALETTE_FILE" ] && [ -f "$PALETTE_FILE" ]; then
    json_on_s=$(grep -iE '"(mOnSecondary|on_secondary)"' "$PALETTE_FILE" | head -n 1 | awk '{print $2}' | tr -d '",#' | tr '[:upper:]' '[:lower:]' || true)
    [ -n "$json_on_s" ] && ON_SECONDARY="$json_on_s"
  elif [ -f "$YAZI_CONF" ]; then
    yazi_on_s=$(grep -E "select_main =.*fg = \"" "$YAZI_CONF" 2>/dev/null | sed -E 's/.*fg = "#([^"]+)".*/\1/' | tr '[:upper:]' '[:lower:]' || true)
    [ -n "$yazi_on_s" ] && ON_SECONDARY="$yazi_on_s"
  elif [ -f "$MATUGEN_JSON" ]; then
    mat_on_s=$(grep -E '"on_secondary":' "$MATUGEN_JSON" 2>/dev/null | awk '{print $2}' | tr -d '",#' | tr '[:upper:]' '[:lower:]' || true)
    [ -n "$mat_on_s" ] && ON_SECONDARY="$mat_on_s"
  fi

  if ! command -v openrgb >/dev/null 2>&1; then
    return 0
  fi

  # 94-LED per-key layout for Wooting 80HE
  LEDS=(
    # Function Row
    "$ON_SECONDARY"  # 0: Escape
    "$ON_PRIMARY"    # 1: F1
    "$ON_PRIMARY"    # 2: F2
    "$ON_PRIMARY"    # 3: F3
    "$ON_PRIMARY"    # 4: F4
    "$SECONDARY"     # 5: F5
    "$SECONDARY"     # 6: F6
    "$SECONDARY"     # 7: F7
    "$SECONDARY"     # 8: F8
    "$ON_PRIMARY"    # 9: F9
    "$ON_PRIMARY"    # 10: F10
    "$ON_PRIMARY"    # 11: F11
    "$ON_PRIMARY"    # 12: F12
    "$SECONDARY"     # 13: Mode
    "$SECONDARY"     # 14: Print Screen
    "$SECONDARY"     # 15: Pause/Break

    # Number Row
    "$SECONDARY"     # 16: ^ / `
    "$PRIMARY"       # 17: 1
    "$PRIMARY"       # 18: 2
    "$PRIMARY"       # 19: 3
    "$PRIMARY"       # 20: 4
    "$PRIMARY"       # 21: 5
    "$PRIMARY"       # 22: 6
    "$PRIMARY"       # 23: 7
    "$PRIMARY"       # 24: 8
    "$PRIMARY"       # 25: 9
    "$PRIMARY"       # 26: 0
    "$PRIMARY"       # 27: -
    "$PRIMARY"       # 28: +
    "$PRIMARY"       # 29: JIS / Backslash
    "$SECONDARY"     # 30: Backspace
    "$SECONDARY"     # 31: Insert
    "$SECONDARY"     # 32: Home

    # QWERTY Row
    "$SECONDARY"     # 33: Tab
    "$PRIMARY"       # 34: Q
    "$PRIMARY"       # 35: W
    "$PRIMARY"       # 36: E
    "$PRIMARY"       # 37: R
    "$PRIMARY"       # 38: T
    "$PRIMARY"       # 39: Y
    "$PRIMARY"       # 40: U
    "$PRIMARY"       # 41: I
    "$PRIMARY"       # 42: O
    "$PRIMARY"       # 43: P
    "$PRIMARY"       # 44: [
    "$PRIMARY"       # 45: ]
    "$PRIMARY"       # 46: \
    "$SECONDARY"     # 47: Delete
    "$SECONDARY"     # 48: End

    # Home Row
    "$SECONDARY"     # 49: Caps Lock
    "$PRIMARY"       # 50: A
    "$PRIMARY"       # 51: S
    "$PRIMARY"       # 52: D
    "$PRIMARY"       # 53: F
    "$PRIMARY"       # 54: G
    "$PRIMARY"       # 55: H
    "$PRIMARY"       # 56: J
    "$PRIMARY"       # 57: K
    "$PRIMARY"       # 58: L
    "$PRIMARY"       # 59: ;
    "$PRIMARY"       # 60: '
    "$PRIMARY"       # 61: #
    "$ON_SECONDARY"  # 62: Enter

    # Bottom Row
    "$SECONDARY"     # 63: Left Shift
    "$PRIMARY"       # 64: \ (ISO)
    "$PRIMARY"       # 65: Z
    "$PRIMARY"       # 66: X
    "$PRIMARY"       # 67: C
    "$PRIMARY"       # 68: V
    "$PRIMARY"       # 69: B
    "$PRIMARY"       # 70: N
    "$PRIMARY"       # 71: M
    "$PRIMARY"       # 72: ,
    "$PRIMARY"       # 73: .
    "$PRIMARY"       # 74: /
    "$PRIMARY"       # 75: JIS
    "$SECONDARY"     # 76: Right Shift
    "$ON_SECONDARY"  # 77: Up Arrow

    # Modifiers & Spacebar / 80HE Light Bar
    "$SECONDARY"     # 78: Left Control
    "$SECONDARY"     # 79: Left Windows
    "$SECONDARY"     # 80: Left Alt
    "$SECONDARY"     # 81: JIS
    "$ON_PRIMARY"    # 82: Spacebar LED 1
    "$ON_PRIMARY"    # 83: Spacebar LED 2
    "$ON_SECONDARY"  # 84: Key: Space
    "$ON_PRIMARY"    # 85: Spacebar LED 3
    "$ON_PRIMARY"    # 86: Spacebar LED 4
    "$SECONDARY"     # 87: JIS
    "$SECONDARY"     # 88: Right Alt
    "$SECONDARY"     # 89: Right Windows
    "$SECONDARY"     # 90: Right Fn
    "$ON_SECONDARY"  # 91: Left Arrow
    "$ON_SECONDARY"  # 92: Down Arrow
    "$ON_SECONDARY"  # 93: Right Arrow
  )

  COLORS=$(IFS=,; echo "${LEDS[*]}")

  # 1. Try fast OpenRGB client mode via background SDK server
  if openrgb --client 127.0.0.1:6742 --device "Wooting" --color "$COLORS" --device "B550" --color "$PRIMARY" 2>/dev/null; then
    echo "[openrgb-wooting] Synced Noctalia theme: primary=#$PRIMARY, secondary=#$SECONDARY, on_primary=#$ON_PRIMARY, on_secondary=#$ON_SECONDARY"
    return 0
  fi

  # 2. Fallback to direct execution
  if openrgb --device "Wooting" --color "$COLORS" --device "B550" --color "$PRIMARY" 2>/dev/null || \
     openrgb --device 1 --color "$COLORS" 2>/dev/null; then
    echo "[openrgb-wooting] Synced Noctalia theme (direct): primary=#$PRIMARY"
    return 0
  fi
}

if [ "${1:-}" = "--watch" ] || [ "${1:-}" = "-w" ]; then
  apply_theme
  TARGET_DIR="$(dirname "$KITTY_CONF")"
  NOCTALIA_DIR="$(dirname "$SETTINGS_CONF")"

  if command -v inotifywait >/dev/null 2>&1; then
    inotifywait -m -q -e close_write,moved_to,create "$TARGET_DIR" "$NOCTALIA_DIR" 2>/dev/null | while read -r _; do
      sleep 0.3
      apply_theme
    done
  else
    LAST_STATE=""
    while true; do
      CUR_STATE=$(stat -c "%Y_%s" "$KITTY_CONF" "$SETTINGS_CONF" 2>/dev/null | tr '\n' '-')
      if [ -n "$CUR_STATE" ] && [ "$CUR_STATE" != "$LAST_STATE" ]; then
        if [ -n "$LAST_STATE" ]; then
          sleep 0.3
          apply_theme
        fi
        LAST_STATE=$(stat -c "%Y_%s" "$KITTY_CONF" "$SETTINGS_CONF" 2>/dev/null | tr '\n' '-')
      fi
      sleep 1
    done
  fi
else
  apply_theme
fi
