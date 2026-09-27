#!/usr/bin/env bash
# Neovim & LazyVim Cheat Sheet Search Viewer
# Dynamically parses docs/neovim-cheatsheet.md and launches Noctalia dmenu.
# Formatted in clean 2-column layout to prevent line clipping.
# Selecting an item copies the keybinding to clipboard or expands full reference in terminal.

CHEATSHEET_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mango/docs/neovim-cheatsheet.md"
if [ ! -f "$CHEATSHEET_FILE" ]; then
  CHEATSHEET_FILE="$HOME/mangoNix/docs/neovim-cheatsheet.md"
fi

generate_entries() {
  echo "📖 [Expand Reference]  │ Open full scrollable cheat sheet in popup window"

  if [ -f "$CHEATSHEET_FILE" ]; then
    awk -F "|" '
    /^\|[[:space:]]*`/ {
      key = $2
      action = $3
      desc = $4

      # Clean backticks and bold markdown tags
      gsub(/[`*]/, "", key)
      gsub(/[`*]/, "", action)
      gsub(/[`*]/, "", desc)

      # Trim whitespace
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", action)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)

      # Format: 2-column layout so it never exceeds launcher width
      if (key != "" && desc != "") {
        printf "%-22s │ %s\n", key, desc
      } else if (key != "" && action != "") {
        printf "%-22s │ %s\n", key, action
      }
    }
    ' "$CHEATSHEET_FILE"
  else
    # Fallback list if file is moved
    cat <<'EOF'
<Space>                │ Default leader prefix for LazyVim commands
<leader><space>        │ Fuzzy find files from project root
<leader>/              │ Search project text in real time (Live Grep)
<leader>,              │ Quick picker to switch between open buffers
<leader>e              │ Toggle file tree sidebar (Neo-tree / Snacks)
<leader>ff             │ Find files relative to current working dir
<leader>fr             │ Search recently opened files
<leader>fb             │ List active open buffers
<leader>sg             │ Project-wide string grep search
<leader>sw             │ Search occurrences of word under cursor
<leader>sk             │ Interactive keymap search with Which-Key
<leader>ca             │ Code action menu (fixes, refactorings)
<leader>cr             │ Project-wide symbol rename with live preview
<leader>cf             │ Format active file via Conform / LSP
<leader>cd             │ Display line error and warning details
<leader>xx             │ Open Trouble diagnostics list
<leader>gg             │ Launch full terminal LazyGit in floating overlay
<leader>gp             │ Preview git diff hunk inline at cursor
[h / ]h                │ Jump to previous / next uncommitted git hunk
<leader>hs / <leader>hr│ Stage / Reset git hunk under cursor
gd                     │ Jump to symbol definition
gr                     │ List all project references for symbol
K                      │ Show type signature, docs, and parameters
ciw / diw / yiw        │ Change / Delete / Yank inside current word
ci" / di" / yi"        │ Change / Delete / Yank inside quotes
gcc                    │ Toggle line comment for current line
gc<motion>             │ Toggle comment for target motion (e.g. gcap)
saiw<char>             │ Wrap inner word with character (e.g. saiw")
sd<char>               │ Delete surrounding characters (e.g. sd")
sr<old><new>           │ Replace surrounding character (e.g. sr"')
s                      │ Flash jump (type 2 characters to jump anywhere)
<C-w>v                 │ Split current window vertically side-by-side
<C-w>s                 │ Split current window horizontally top-and-bottom
<C-h/j/k/l>            │ Move focus to Left / Down / Up / Right split
<C-w>c                 │ Close current split pane
[b / ]b                │ Cycle to previous / next active buffer
<leader>bd             │ Close current buffer preserving split layout
<leader>l              │ Open Lazy plugin manager (:Lazy)
<leader>cm             │ Open Mason package manager (:Mason)
:w                     │ Write changes to current file
:q / :wq               │ Close window / Save and close file
:qa!                   │ Force quit all without saving
EOF
  fi
}

LAUNCHER="noctalia"
for arg in "$@"; do
  case "$arg" in
    --fuzzel|-f) LAUNCHER="fuzzel" ;;
    --noctalia|-n) LAUNCHER="noctalia" ;;
  esac
done

if [ "$LAUNCHER" = "fuzzel" ] && command -v fuzzel >/dev/null 2>&1; then
  SELECTED=$(generate_entries | fuzzel -d -p "Neovim Cheat Sheet: " -w 95 -l 24 --placeholder="Search motions, keys, LSP, splits...")
else
  SELECTED=$(generate_entries | noctalia dmenu -p "Neovim Cheat Sheet")
fi

if [ -z "$SELECTED" ]; then
  exit 0
fi

# If user selected expand reference, open in a floating terminal with bat/less
if [[ "$SELECTED" == *"📖 [Expand Reference]"* ]]; then
  if command -v bat >/dev/null 2>&1; then
    ghostty --title="Neovim Cheat Sheet" -e bat --paging=always "$CHEATSHEET_FILE" &
  else
    ghostty --title="Neovim Cheat Sheet" -e less -R "$CHEATSHEET_FILE" &
  fi
  exit 0
fi

# Extract key and description
KEY=$(echo "$SELECTED" | awk -F "│" '{print $1}' | sed 's/[[:space:]]*$//; s/^[[:space:]]*//')
DESC=$(echo "$SELECTED" | awk -F "│" '{print $2}' | sed 's/[[:space:]]*$//; s/^[[:space:]]*//')

# Copy key to clipboard
if command -v wl-copy >/dev/null 2>&1; then
  wl-copy "$KEY" 2>/dev/null || true
fi
if command -v noctalia >/dev/null 2>&1; then
  noctalia msg clipboard-copy "$KEY" 2>/dev/null || true
fi

# Send desktop notification
if command -v noctalia >/dev/null 2>&1; then
  noctalia msg notification-show "Neovim Cheat Sheet" "Copied '$KEY' to clipboard\n$DESC" 2>/dev/null || true
fi
