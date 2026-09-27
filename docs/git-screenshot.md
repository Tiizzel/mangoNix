# 📸 mangoNix — GitHub & GitLab Screenshot Showcase Guide

This guide outlines the recommended screenshot gallery structure and provides a ready-to-use Markdown section to embed directly into your repository's [`README.md`](file:///home/tiizzel/mangoNix/README.md).

---

## 🎯 Screenshot Capture Plan & Highlighting Strategy

| # | Screenshot Name | Key Elements to Display | Why It Matters |
|---|-----------------|-------------------------|----------------|
| **1** | `hero-desktop.png` | **MangoWM** tiling layout with **Zen Browser**, **Ghostty** (`fastfetch` + `btop`), **Neovim** (LazyVim), and **Noctalia** top panel. | High-impact hero view showing daily glassmorphic workflow. |
| **2** | `matugen-theme-sync.png` | Side-by-side or split view demonstrating automatic **Matugen** wallpaper color sync across window borders, terminals, status bar, and Neovim. | Highlights core automated Material You palette generation. |
| **3** | `noctalia-controls.png` | **Noctalia Control Center** (`SUPER + SHIFT + c`), App Launcher (`SUPER + Space`), and NordVPN status bar widget. | Showcases the custom Wayland shell controls and interactive widgets. |
| **4** | `cheat-sheet-modals.png` | **Keybindings modal** (`SUPER + .`) and **Neovim Cheat Sheet** (`SUPER + ,`) open on desktop. | Demonstrates built-in user experience and keybind accessibility. |
| **5** | `terminal-power-tools.png` | **Yazi** file manager (`SUPER + y`), **Oh My Posh** Zen prompt, and `nh` rebuild command (`fr`). | Appeals to power users, terminal enthusiasts, and Nix developers. |
| **6** | `sddm-astronaut.png` | **SDDM Astronaut** login screen with dynamic wallpaper background and Matugen accents. | Displays design consistency from boot/login to desktop session. |

---

## 📸 Capture Workflow

Capture screenshots using built-in **mangoNix** hotkeys:
* `SUPER + s`: Select region / window
* `SUPER + CTRL + s`: Fullscreen capture
* `SUPER + SHIFT + s`: Capture and annotate with Satty

Recommended local directory for repository assets:
```bash
mkdir -p ~/mangoNix/docs/assets
# Save screenshots into ~/mangoNix/docs/assets/
```

---

## 📄 README.md Gallery Snippet (Copy & Paste)

Copy the Markdown snippet below directly into your repository's `README.md`:

```markdown
## 🎨 Desktop Showcase & Gallery

<p align="center">
  <img src="docs/assets/hero-desktop.png" alt="mangoNix Hero Desktop" width="100%">
  <br>
  <em><b>Figure 1:</b> MangoWM tiling layout featuring Zen Browser, Ghostty, Neovim, and the Noctalia shell panel.</em>
</p>

<details>
<summary><b>📸 Click to expand the full visual showcase</b></summary>

<br>

### 🌈 1. Dynamic Matugen Palette Sync
> Changing wallpapers dynamically re-themes MangoWM borders, Ghostty/Kitty terminals, Noctalia widgets, Oh My Posh, and Neovim in real-time (`SUPER + ALT + t`).

<p align="center">
  <img src="docs/assets/matugen-theme-sync.png" alt="Dynamic Matugen Theme Sync" width="95%">
</p>

---

### 🌌 2. Noctalia Shell & Custom Control Center
> Fast, native Wayland desktop shell providing app launcher, control center, clipboard history, and NordVPN controls.

<p align="center">
  <img src="docs/assets/noctalia-controls.png" alt="Noctalia Shell Controls" width="95%">
</p>

---

### ⌨️ 3. Built-In Cheat Sheet Overlays
> Access interactive keybindings (`SUPER + .`) and Neovim cheat sheets (`SUPER + ,`) instantly via Noctalia or Fuzzel modals.

<p align="center">
  <img src="docs/assets/cheat-sheet-modals.png" alt="Interactive Cheat Sheet Overlays" width="95%">
</p>

---

### ⚡ 4. Terminal Stack & Daily Rebuilds
> Powered by Yazi file manager, Ghostty GPU terminal, Oh My Posh Zen prompt, and `nh` NixOS rebuild helper (`fr`).

<p align="center">
  <img src="docs/assets/terminal-power-tools.png" alt="Terminal Power Tools" width="95%">
</p>

---

### 🔒 5. SDDM Astronaut Display Manager
> Unified login experience with dynamic wallpaper syncing and Material You color accents.

<p align="center">
  <img src="docs/assets/sddm-astronaut.png" alt="SDDM Astronaut Login Theme" width="95%">
</p>

</details>
```
