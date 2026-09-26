# 🥭 mangoNix — Shared Gemini Notebook Bridge

> **About this file**: This document serves as a shared context bridge between **Gemini Notebook (NotebookLM)** and **Antigravity IDE**.
> - In **Antigravity IDE**: The AI assistant can read, write, update, and implement plans documented here.
> - In **Gemini Notebook**: Import this file (or its GitHub link) as a notebook source to analyze, query, brainstorm, and take notes.

---

## 📌 System & Repository Overview

- **Repository**: `mangoNix`
- **Architecture**: NixOS Flake configuration with modular aspects and Home-Manager/system integrations.
- **Desktop Environment**: Noctalia Desktop Shell & MangoWM.
- **Primary Browser**: Zen Browser (`zen-beta`) with fallback to Firefox.
- **Styling & Theming**: Dynamic Material You palette generation via `matugen` synchronized across Noctalia, Kitty, Ghostty, Spicetify, and system apps.

---

## 🚀 Active Components & Recent Features

### 1. WebApp Manager (`create-webapp` / `webapp`)
- **Location**: `modules/apps/webapps.nix`
- **Commands**: `webapp` or `create-webapp`
- **Capabilities**:
  - **Browser Auto-Detection**: Queries `xdg-settings` / `xdg-mime` and prioritizes Zen Browser (`zen-beta`), falling back to Firefox.
  - **Interactive Creation**: Select browser, URL, icon, profile mode, and categories with automatic high-resolution icon retrieval.
  - **Editing Existing WebApps**: `webapp --edit` allows changing browser, profile mode (shared vs. isolated), app name, URL, and icons.
  - **Session Preservation**: Default shared browser profile mode (`ISOLATED=0`) keeps you logged into web services.
  - **Atomic Updates & Shell Integration**: Writes desktop entries atomically via temporary files and sends IPC reload signals to Noctalia shell (`noctalia msg dock-reload` / `config-reload`).

---

## 📝 Gemini Notebook Notes & Research

*(Paste or export notes, architecture ideas, or research from Gemini Notebook / NotebookLM here for Antigravity to review and implement)*

### Ideas & Brainstorming
- 

### Questions / Decisions
- 

---

## 📋 Task Backlog & Improvement Roadmap

### Completed Tasks
- [x] Configure Zen Browser (`zen-beta`) as default webapp runner.
- [x] Implement atomic `.desktop` file generation to prevent launcher race conditions.
- [x] Add interactive and CLI `--edit` feature to modify installed webapps.
- [x] Create shared documentation bridge for Gemini Notebook.

### ⌨️ Keybindings & Desktop UX
- [ ] **On-Screen Keybind Overlay:** Add a keybinding (e.g. `SUPER + k` or `SUPER + /`) in MangoWM / Noctalia to trigger a cheat sheet pop-up overlay.
- [ ] **Custom Widget Toggles:** Extend Noctalia control center widgets for quick audio output switching and VPN controls.
- [ ] **Scratchpad Enhancements:** Add multi-window scratchpad support in MangoWM.

### 🔧 System & Nix Flakes Automation
- [ ] **SOPS Key Bootstrapping:** Automate Age key generation and decryption during fresh setup when `options.var.enableSops` is set to `true`.
- [ ] **Installer Hardening:** Expand `install.sh` to support custom disk partition setups and multi-monitor layout selection.
- [ ] **Nix GC Hook Automation:** Configure scheduled background cleanup for old Nix store generations using `nh`.

### 🎨 Theming & Aesthetics
- [ ] **Extended Matugen Support:** Hook Matugen color palettes into Vesktop (Discord), Neovim, Btop, and GTK4 apps.
- [ ] **Light Mode Fallback:** Add light mode color palette templates for Matugen when using light wallpapers.
- [ ] **SDDM Theme Sync:** Automatically sync SDDM background and colors with current Matugen palette.

### 🎮 Hardware, Drivers & Gaming
- [ ] **LACT Overclock Profiles:** Fine-tune AMDGPU fan curves and overdrive power targets in `modules/hardware/`.
- [ ] **Wooting Integration:** Sync Wooting keyboard RGB profiles with active Matugen theme colors.
- [ ] **Steam & Gamescope Tuning:** Add pre-configured Gamescope launch wrappers for Wayland gaming.

### 📁 Dotfiles & Home-Manager Maintenance
- [ ] **Zen Browser Auto-Update Sync:** Automate validation of `userChrome.css` and `user.js` against newer Zen Browser versions.
- [ ] **Dotfile Symlink Validation:** Add automated check in `install.sh` to verify all symlinks under `~/mangoNix/dotfiles/` exist.
