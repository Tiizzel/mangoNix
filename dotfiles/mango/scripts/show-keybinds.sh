#!/usr/bin/env bash
# MangoWM / Noctalia Keybindings Search Viewer
# Dynamically reads keybinds.conf and extracts descriptions from comments
# directly preceding each keybind or inline on the same line.

KEYBINDS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mango/cfg/keybinds.conf"
if [ ! -f "$KEYBINDS_FILE" ]; then
  KEYBINDS_FILE="$HOME/mangoNix/dotfiles/mango/cfg/keybinds.conf"
fi

if [ ! -f "$KEYBINDS_FILE" ]; then
  echo "Keybinds configuration not found: $KEYBINDS_FILE" >&2
  exit 1
fi

generate_list() {
  awk '
  # Skip empty lines
  /^[[:space:]]*$/ { next }

  # Match comment lines
  /^[[:space:]]*#/ {
    line = $0
    sub(/^[[:space:]]*#[[:space:]]*/, "", line)

    # Ignore section header dividers like "=== APPLICATIONS ===" or empty comments
    if (line !~ /^[=]/ && line !~ /^[|]/ && line != "") {
      last_comment = line
    }
    next
  }

  # Match keybinding lines
  /^[[:space:]]*bind/ {
    raw_line = $0
    inline_comment = ""

    # Check for inline comment after "#"
    if (raw_line ~ /#/) {
      split(raw_line, cparts, "#")
      raw_line = cparts[1]
      inline_comment = cparts[2]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", inline_comment)
    }

    # Extract after "bind ="
    split(raw_line, eqparts, "=")
    bind_def = eqparts[2]
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", bind_def)

    split(bind_def, parts, ",[[:space:]]*")
    mod = parts[1]
    key = parts[2]
    cmd = parts[3]
    arg = parts[4]
    for (i=5; i<=length(parts); i++) arg = arg ", " parts[i]

    # Prettify modifier names
    gsub("SUPER", "Super", mod)
    gsub("SHIFT", "Shift", mod)
    gsub("CTRL", "Ctrl", mod)
    gsub("ALT", "Alt", mod)

    combo = (mod == "NONE" || mod == "") ? key : mod " + " key

    # Priority: 1. Inline comment -> 2. Preceding line comment -> 3. Raw action fallback
    desc = inline_comment
    if (desc == "") desc = last_comment
    if (desc == "") {
      if (cmd == "spawn") desc = arg
      else if (arg != "") desc = cmd " " arg
      else desc = cmd
    }

    printf "%-26s │ %s\n", combo, desc
    last_comment = ""
  }
  ' "$KEYBINDS_FILE"
}

LAUNCHER="noctalia"
for arg in "$@"; do
  case "$arg" in
    --fuzzel|-f) LAUNCHER="fuzzel" ;;
    --noctalia|-n) LAUNCHER="noctalia" ;;
  esac
done

if [ "$LAUNCHER" = "fuzzel" ] && command -v fuzzel >/dev/null 2>&1; then
  SELECTED=$(generate_list | fuzzel -d -p "Keybindings: " -w 95 -l 24 --placeholder="Search shortcuts or actions...")
else
  SELECTED=$(generate_list | noctalia dmenu -p "Keybindings")
fi

if [ -z "$SELECTED" ]; then
  exit 0
fi

# Lookup and execute selected binding action if user presses Enter
COMBO=$(echo "$SELECTED" | awk -F "│" '{print $1}' | sed 's/[[:space:]]*$//')

MATCHED_ACTION=$(awk -F "=" -v target="$COMBO" '
/^[[:space:]]*bind/ {
  raw_line = $0
  if (raw_line ~ /#/) {
    split(raw_line, cparts, "#")
    raw_line = cparts[1]
  }
  split(raw_line, eqparts, "=")
  bind_def = eqparts[2]
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", bind_def)

  split(bind_def, parts, ",[[:space:]]*")
  mod = parts[1]; key = parts[2]
  gsub("SUPER", "Super", mod); gsub("SHIFT", "Shift", mod); gsub("CTRL", "Ctrl", mod); gsub("ALT", "Alt", mod)
  c = (mod == "NONE" || mod == "") ? key : mod " + " key
  if (c == target) {
    cmd = parts[3]
    arg = parts[4]
    for (i=5; i<=length(parts); i++) arg = arg ", " parts[i]
    if (cmd == "spawn") print "SPAWN:" arg
    else if (arg != "") print "DISPATCH:" cmd " " arg
    else print "DISPATCH:" cmd
    exit
  }
}
' "$KEYBINDS_FILE")

if [[ "$MATCHED_ACTION" == SPAWN:* ]]; then
  EXEC_CMD="${MATCHED_ACTION#SPAWN:}"
  eval "$EXEC_CMD" &
elif [[ "$MATCHED_ACTION" == DISPATCH:* ]]; then
  DISPATCH_CMD="${MATCHED_ACTION#DISPATCH:}"
  if command -v mmsg >/dev/null 2>&1; then
    mmsg dispatch $DISPATCH_CMD >/dev/null 2>&1 || true
  fi
fi
