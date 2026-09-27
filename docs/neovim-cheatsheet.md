# ⚡ Neovim & LazyVim Cheat Sheet

A comprehensive reference for Neovim with the LazyVim distribution, tuned for productivity and quick lookups.

---

## 🚀 Essentials & Leader Key

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `<Space>` | **Leader Key** | Default leader prefix for LazyVim key combinations |
| `:w` | **Save** | Write changes to current file |
| `:q` | **Quit** | Close current window |
| `:wq` / `ZZ` | **Save & Quit** | Write changes and close file |
| `:qa!` / `ZQ` | **Force Quit All** | Exit Neovim without saving modifications |
| `u` | **Undo** | Revert last change |
| `<C-r>` | **Redo** | Reapply undone change |
| `.` | **Repeat** | Repeat last editing operation |
| `<Esc>` / `<C-[>` | **Normal Mode** | Return to Normal mode from Insert/Visual |

---

## 🔍 Find & Pickers (Snacks / Telescope)

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `<leader><space>` | **Smart Find Files** | Fuzzy find files from project root |
| `<leader>/` | **Live Grep** | Search project text in real time |
| `<leader>,` | **Switch Buffer** | Quick picker to switch between open buffers |
| `<leader>e` | **Explorer Toggle** | Toggle file tree sidebar (Neo-tree / Snacks) |
| `<leader>ff` | **Find Files (cwd)** | Find files relative to current working directory |
| `<leader>fr` | **Recent Files** | Search recently opened files |
| `<leader>fb` | **Buffer List** | Search active open buffers |
| `<leader>fn` | **New File** | Create and open a new empty buffer |
| `<leader>sg` | **Search Grep** | Project-wide string grep search |
| `<leader>sw` | **Search Word** | Search occurrences of word under cursor |
| `<leader>sk` | **Search Keymaps** | Interactive keymap search with Which-Key |
| `<leader>sh` | **Search Help** | Search Neovim documentation help tags |
| `<leader>sd` | **Search Diagnostics** | Search LSP workspace warnings and errors |
| `<leader>sR` | **Resume Search** | Resume the most recent picker query |

---

## 🧭 Navigation & Motions

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `h / j / k / l` | **Basic Movement** | Move cursor Left / Down / Up / Right |
| `w / b / e` | **Word Motions** | Move to next word start / previous word start / word end |
| `W / B / E` | **WORD Motions** | Move by whitespace-delimited WORDs |
| `0 / ^ / $` | **Line Boundaries** | Column 0 / First non-blank char / End of line |
| `gg / G` | **File Boundaries** | Jump to first line / last line of file |
| `:<N>` / `<N>G` | **Goto Line** | Jump directly to line number N |
| `<C-d> / <C-u>` | **Half-Page Scroll** | Scroll down / up by half a page (centered) |
| `%` | **Matching Pair** | Jump between matching brackets `()`, `{}`, `[]`, `<>` |
| `* / #` | **Word Search** | Search next / previous occurrence of word under cursor |
| `s` | **Flash Jump** | Type 2 characters to jump anywhere on screen instantly |
| `S` | **Flash Treesitter** | Select and jump to Treesitter syntax nodes |

---

## ✏️ Editing, Text Objects & Surround

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `i / a` | **Insert / Append** | Enter Insert mode before / after cursor |
| `I / A` | **Line Insert / Append** | Enter Insert mode at line start / line end |
| `o / O` | **Open Line** | Create blank line below / above cursor and insert |
| `ciw / diw / yiw` | **Inner Word** | Change / Delete / Yank inside current word |
| `ci" / di" / yi"` | **Inside Quotes** | Change / Delete / Yank inside `"..."` |
| `ca" / da" / ya"` | **Around Quotes** | Change / Delete / Yank including quotes |
| `ci( / di( / yi(` | **Inside Parens** | Change / Delete / Yank inside `(...)` |
| `cit / dit / yit` | **Inside Tags** | Change / Delete / Yank inside HTML/XML `<tag>` |
| `dd / yy / cc` | **Line Operations** | Delete / Yank / Change entire line |
| `D / C` | **To Line End** | Delete / Change from cursor to end of line |
| `p / P` | **Paste** | Paste clipboard after / before cursor |
| `gcc` | **Comment Line** | Toggle line comment |
| `gc<motion>` | **Comment Motion** | Toggle comment for target motion (e.g. `gcap`) |
| `saiw<char>` | **Surround Add** | Wrap inner word with character (e.g. `saiw"` → `"word"`) |
| `sd<char>` | **Surround Delete** | Delete surrounding characters (e.g. `sd"` removes `"`) |
| `sr<old><new>` | **Surround Replace** | Replace surrounding character (e.g. `sr"'` → `'word'`) |
| `v / V / <C-v>` | **Visual Modes** | Character visual / Line visual / Block column visual |
| `> / <` | **Indent / Unindent** | Indent or unindent selected lines |

---

## 🪟 Windows & Split Panes

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `<C-w>v` | **Split Vertical** | Split current window vertically side-by-side |
| `<C-w>s` | **Split Horizontal** | Split current window horizontally top-and-bottom |
| `<C-h/j/k/l>` | **Navigate Splits** | Move focus to Left / Down / Up / Right split window |
| `<C-w>c` / `<C-w>q` | **Close Split** | Close current split pane |
| `<C-w>o` | **Close Others** | Maximize current split by closing all other panes |
| `<C-w>=` | **Balance Splits** | Reset all split windows to equal sizes |
| `<C-Up/Down/Left/Right>` | **Resize Splits** | Expand or contract current split dimensions |

---

## 📑 Buffers & Tabs

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `[b / ]b` | **Previous / Next Buffer** | Cycle to previous / next active buffer |
| `<S-h> / <S-l>` | **Bufferline Cycle** | Jump left / right across buffer tabs |
| `<leader>bd` | **Close Buffer** | Delete current buffer while preserving split layout |
| `<leader>bD` | **Force Close Window** | Close buffer and its containing split window |
| `<leader>bo` | **Close Other Buffers** | Close all buffers except the current active one |
| `<leader>bp` | **Pin Buffer** | Pin buffer to prevent accidental closing |
| `<leader>bP` | **Delete Non-Pinned** | Delete all unpinned buffers |

---

## 🧠 LSP, Diagnostics & Code Intelligence

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `gd` | **Goto Definition** | Jump to symbol definition |
| `gr` | **Goto References** | List all project references for symbol |
| `gI` | **Goto Implementation** | Jump to interface/trait implementation |
| `gy` | **Goto Type Definition** | Jump to data type definition |
| `K` | **Hover Info** | Show type signature, docs, and parameter types |
| `<leader>ca` | **Code Action** | Open code action menu (fixes, refactorings, imports) |
| `<leader>cr` | **Rename Symbol** | Project-wide symbol rename with live preview |
| `<leader>cf` | **Format Document** | Format active file or selection via Conform / LSP |
| `<leader>cd` | **Line Diagnostics** | Display error / warning details for current line |
| `[d / ]d` | **Prev / Next Error** | Jump to previous / next diagnostic issue |
| `<leader>xx` | **Trouble Diagnostics** | Open interactive Trouble list of project errors |
| `<leader>xX` | **Trouble Buffer** | Open Trouble list filtered to current buffer only |
| `<leader>cs` | **Document Symbols** | Browse symbols outline tree for current file |

---

## 🌿 Git Integration (Gitsigns & LazyGit)

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `<leader>gg` | **LazyGit** | Launch full terminal LazyGit in a floating overlay |
| `<leader>gp` | **Preview Hunk** | Preview git diff hunk inline at cursor |
| `[h / ]h` | **Prev / Next Hunk** | Jump to previous / next uncommitted git hunk |
| `<leader>hs` | **Stage Hunk** | Stage git hunk under cursor |
| `<leader>hr` | **Reset Hunk** | Discard / revert git hunk changes under cursor |
| `<leader>gb` | **Git Blame** | View git blame annotation for current line |
| `<leader>gl` | **Git Commits** | Browse project git commit history |

---

## ⚙️ LazyVim UI & Sessions

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `<leader>l` | **Lazy Dashboard** | Open Lazy plugin management interface |
| `<leader>cm` | **Mason Manager** | Open Mason package installer for LSPs/formatters |
| `<leader>un` | **Toggle Line Numbers** | Toggle between relative, absolute, and hidden numbers |
| `<leader>ud` | **Toggle Diagnostics** | Toggle inline LSP error virtual text on/off |
| `<leader>uw` | **Toggle Word Wrap** | Toggle visual soft word wrapping |
| `<leader>uc` | **Toggle Conceal** | Toggle markdown conceal formatting |
| `<leader>qs` | **Restore Session** | Restore previous workspace session (Persistence) |
| `<leader>ql` | **Restore Last Session** | Restore the most recent workspace session |
| `<leader>qd` | **Stop Session Save** | Prevent saving current session upon quit |
