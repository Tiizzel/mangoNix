# 🥭 mangoNix — Shared Gemini Notebook Bridge

> **About this file**: This document serves as a shared context bridge between **Gemini Notebook (NotebookLM)** and **Antigravity IDE**.
> - In **Antigravity IDE**: The AI assistant can read, write, update, and implement plans documented here.
> - In **Gemini Notebook**: Import this file (or its GitHub link) as a notebook source to analyze, query, brainstorm, and take notes.

---

## 📌 System & Repository Overview

- **Repository**: `mangoNix`
- **Architecture**: NixOS Flake configuration with modular aspects (`flake-parts`, `flake-aspects`, `import-tree`) and Home-Manager/system integrations.
- **Desktop Environment**: Noctalia Desktop Shell & MangoWM (v0.17.0+).
- **Primary Browser**: Zen Browser (`zen-beta`) with fallback to Firefox.
- **Styling & Theming**: Dynamic Material You palette generation via `matugen` synchronized across Noctalia, Kitty, Ghostty, Spicetify, SDDM Astronaut, Wooting 80HE OpenRGB, and system apps.

---

## 🚀 Active Components & Recent Features

### 1. WebApp Manager (`create-webapp` / `webapp`)
- **Location**: [`modules/apps/webapps.nix`](file:///home/tiizzel/mangoNix/modules/apps/webapps.nix)
- **Commands**: `webapp` or `create-webapp`
- **Capabilities**:
  - **Browser Auto-Detection**: Queries `xdg-settings` / `xdg-mime` and prioritizes Zen Browser (`zen-beta`), falling back to Firefox.
  - **Interactive Creation**: Select browser, URL, icon, profile mode, and categories with automatic high-resolution icon retrieval.
  - **Editing Existing WebApps**: `webapp --edit` allows changing browser, profile mode (shared vs. isolated), app name, URL, and icons.
  - **Session Preservation**: Default shared browser profile mode (`ISOLATED=0`) keeps you logged into web services.
  - **Atomic Updates & Shell Integration**: Writes desktop entries atomically via temporary files and sends IPC reload signals to Noctalia shell (`noctalia msg dock-reload` / `config-reload`).

### 2. Interactive Keybind & Neovim Overlays
- **Keybind Cheat Sheet**: Triggered via `SUPER + .` (Noctalia modal) or `SUPER + CTRL + .` (Fuzzel Wide Modal) running [`show-keybinds.sh`](file:///home/tiizzel/mangoNix/dotfiles/mango/scripts/show-keybinds.sh).
- **Neovim / LazyVim Cheat Sheet**: Triggered via `SUPER + ,` (Noctalia modal) or `SUPER + CTRL + ,` (Fuzzel Wide Modal) running [`show-neovim-cheatsheet.sh`](file:///home/tiizzel/mangoNix/dotfiles/mango/scripts/show-neovim-cheatsheet.sh) referencing [`docs/neovim-cheatsheet.md`](file:///home/tiizzel/mangoNix/docs/neovim-cheatsheet.md).

### 3. NordVPN Integration & Control Panel
- **Location**: [`modules/apps/nordvpn.nix`](file:///home/tiizzel/mangoNix/modules/apps/nordvpn.nix)
- **Capabilities**: NordVPN daemon with `nordvpn` group privileges, custom Noctalia status bar widget, and interactive control panel (`custom/nordvpn`).

### 4. SDDM Astronaut & Wooting 80HE RGB Sync
- **Location**: [`modules/login-managers/sddm.nix`](file:///home/tiizzel/mangoNix/modules/login-managers/sddm.nix) and [`modules/theming/openrgb.nix`](file:///home/tiizzel/mangoNix/modules/theming/openrgb.nix)
- **Capabilities**: Dynamic active wallpaper sync for SDDM login screen with `purple_leaves` preset, and 94-LED Matugen color template with OpenRGB daemon synchronization script (`dotfiles/openrgb/apply-wooting-theme.sh`) for Wooting 80HE.

---

## 📝 Gemini Notebook Notes & Research

*(Paste or export notes, architecture ideas, or research from Gemini Notebook / NotebookLM here for Antigravity to review and implement)*

### Ideas & Brainstorming
- 

### Questions / Decisions
- 

---

## 🔗 Related Documentation & Roadmaps

- 📋 **System TODO & Improvement Roadmap**: [`docs/todo.md`](file:///home/tiizzel/mangoNix/docs/todo.md) — Comprehensive task backlog, MangoWM 0.17.0 enhancements, Noctalia UX, performance tuning, and completed milestones.
- 📸 **GitHub/GitLab Screenshot Showcase Guide**: [`docs/git-screenshot.md`](file:///home/tiizzel/mangoNix/docs/git-screenshot.md) — Highlighting strategy, capture workflow, and gallery snippet for README.md.
- ⌨️ **Neovim & LazyVim Cheat Sheet**: [`docs/neovim-cheatsheet.md`](file:///home/tiizzel/mangoNix/docs/neovim-cheatsheet.md) — Modal keybindings reference and search overlays.
- 🔍 **NixOS Research Guidelines**: [`.agents/rules/nixos-research.md`](file:///home/tiizzel/mangoNix/.agents/rules/nixos-research.md) — Prioritize `mcp-nixos`, [MyNixOS](https://mynixos.com/), [NixOS Search (unstable)](https://search.nixos.org/packages?channel=unstable), and [NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki) alongside other sources.


