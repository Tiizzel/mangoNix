# 📋 mangoNix TODO & System Improvement Roadmap

This roadmap tracks completed milestones and organizes pending system tasks, compositor improvements, gaming/performance tuning, theming hooks, and automations.

---

## 🚀 Recently Completed Milestones

- [x] **PipeWire & WirePlumber Low-Latency Tuning:** Configured PipeWire server and PulseAudio quantum properties (`min-quantum = 32`, `default-quantum = 64`, `max-quantum = 1024`) with ALSA low-latency rules and disabled idle suspend in [`modules/hardware/audio.nix`](file:///home/tiizzel/mangoNix/modules/hardware/audio.nix).
- [x] **Low-Latency Gaming Kernel (CachyOS BORE Zen 3):** Switched to `pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3` optimized for AMD Ryzen 7 5700X with Clang LTO and BORE (Burst-Oriented Response Enhancer) gaming scheduler in [`modules/system/boot.nix`](file:///home/tiizzel/mangoNix/modules/system/boot.nix).
- [x] **Nix Store Auto-Optimization & Periodic GC:** Configured `nix.settings.auto-optimise-store = true` in [`modules/system/nix.nix`](file:///home/tiizzel/mangoNix/modules/system/nix.nix) and enabled automatic `nh clean` background timers (`--keep-since 7d --keep 5`) in [`modules/cli-tools/nh.nix`](file:///home/tiizzel/mangoNix/modules/cli-tools/nh.nix).
- [x] **Zen Browser WebApp Runner:** Default webapp runner via `create-webapp` CLI with auto-browser detection, high-res icon fetching, and atomic desktop generation in [`modules/apps/webapps.nix`](file:///home/tiizzel/mangoNix/modules/apps/webapps.nix).
- [x] **Interactive Keybind & Neovim Overlays:** Configured `SUPER + .` (Keybinds) and `SUPER + ,` (Neovim Cheat Sheet) triggering Noctalia modals and Fuzzel wide fallback overlays.
- [x] **NordVPN System Integration:** Service daemon module with `nordvpn` group privileges, custom Noctalia top bar widget, and interactive control panel (`custom/nordvpn`) in [`modules/apps/nordvpn.nix`](file:///home/tiizzel/mangoNix/modules/apps/nordvpn.nix).
- [x] **SDDM Astronaut Theme Sync:** Configured SDDM Astronaut `purple_leaves` theme with active wallpaper synchronization and Matugen Material colors in [`modules/login-managers/sddm.nix`](file:///home/tiizzel/mangoNix/modules/login-managers/sddm.nix).
- [x] **Wooting 80HE RGB Sync:** Created 94-LED Matugen color template and OpenRGB synchronization script in [`modules/theming/openrgb.nix`](file:///home/tiizzel/mangoNix/modules/theming/openrgb.nix).
- [x] **ZRAM & OOM Daemon Tuning:** Configured compressed in-memory swap (`zramSwap.enable = true` with zstd, priority 100, memoryPercent = 100), `systemd.oomd` userspace protection, and kernel memory sysctl tuning (`vm.swappiness = 180`, `vm.page-cluster = 0`) in [`modules/system/memory.nix`](file:///home/tiizzel/mangoNix/modules/system/memory.nix).
- [x] **Shared Documentation Ecosystem:** Established dedicated bridge documents: [`docs/gemini-notes.md`](file:///home/tiizzel/mangoNix/docs/gemini-notes.md), [`docs/git-screenshot.md`](file:///home/tiizzel/mangoNix/docs/git-screenshot.md), [`docs/neovim-cheatsheet.md`](file:///home/tiizzel/mangoNix/docs/neovim-cheatsheet.md), and [`docs/todo.md`](file:///home/tiizzel/mangoNix/docs/todo.md).

---

## ⚡ Hardware & Gaming Performance (Zero-Overhead & Driver Tuning)

*Low-level driver, kernel, and filesystem optimizations tailored for AMD Ryzen 7 5700X + Radeon RX 7900 XT on Wayland (no GameMode).*

1. **Variable Refresh Rate (VRR / FreeSync) in MangoWM**
   - **Why**: The Samsung Odyssey G9 (5120x1440 @ 240Hz) supports FreeSync Premium Pro, but `dotfiles/mango/cfg/monitors.conf` currently has `vrr:0`.
   - **Action**: Change `vrr:0` to `vrr:1` (or on-demand `vrr:2`) on output `DP-1` in [`dotfiles/mango/cfg/monitors.conf`](file:///home/tiizzel/mangoNix/dotfiles/mango/cfg/monitors.conf).
   - **Benefit**: Completely tear-free, fluid motion with zero latency penalty across all refresh rates up to 240Hz.

3. **Mesa / RADV 16GB Shader Cache & Pipeline Optimizations**
   - **Why**: Heavy Vulkan titles on the RX 7900 XT can easily exceed 4GB of precompiled shaders, causing pipeline rebuild stutters.
   - **Action**: In [`modules/hardware/drivers.nix`](file:///home/tiizzel/mangoNix/modules/hardware/drivers.nix):
     - Increase `MESA_SHADER_CACHE_MAX_SIZE = "16G"`.
     - Add `RADV_PERFTEST = "gpl,sam"` (enables Graphics Pipeline Library fast-linking and Smart Access Memory / Resizable BAR).
     - Add `split_lock_mitigate=0` to `boot.kernelParams` to prevent kernel throttling on unaligned memory access in Steam Proton games.

4. **Btrfs `nodatacow` for Steam & Game Libraries**
   - **Why**: The filesystem is Btrfs. Copy-on-Write (CoW) on Proton prefixes, large game files, and dynamic disk images causes severe write amplification and disk I/O stuttering.
   - **Action**: Add declarative `systemd.tmpfiles.rules` in [`modules/gaming/steam.nix`](file:///home/tiizzel/mangoNix/modules/gaming/steam.nix) to apply `+C` (no-CoW) to `~/.local/share/Steam`, `~/.steam`, and `~/.local/share/wineprefixes`.

5. **Proton Virtual Memory Max Map Count**
   - **Why**: Demanding modern games (Star Citizen, Hogwarts Legacy, DayZ, CS2) can exhaust default Linux memory map limits and crash.
   - **Action**: Add `"vm.max_map_count" = 2147483642;` to sysctl settings in [`modules/system/memory.nix`](file:///home/tiizzel/mangoNix/modules/system/memory.nix).

---

## 🎨 Theming & Visual Aesthetics (What Can Look Better)

*Deepening the Material You dynamic wallpaper synchronization and glassmorphic UI polish.*

6. **Vesktop (Discord) Matugen Dynamic Theme Hook**
   - **Why**: Discord remains in static dark mode while the rest of the desktop adapts to wallpaper colors.
   - **Action**: Create a Matugen template in `dotfiles/matugen/templates/` that generates CSS for Vesktop (`~/.config/vesktop/settings/quickCss.css`), dynamically styling accents, active channels, badges, and hover states.

7. **Btop System Monitor Matugen Palette Hook**
   - **Why**: Currently `dotfiles/btop/themes/noctalia.theme` is edited manually.
   - **Action**: Add a template in [`dotfiles/matugen/config.toml`](file:///home/tiizzel/mangoNix/dotfiles/matugen/config.toml) to automatically re-theme Btop CPU/GPU graphs and memory meters on wallpaper changes.

8. **Yazi Terminal File Manager Matugen Flavor**
   - **Why**: File previewing and directory browsing in Yazi (`SUPER + y`) can dynamically adapt its border and syntax colors to the active wallpaper.
   - **Action**: Hook Matugen color output into `dotfiles/yazi/flavors/noctalia.yazi/flavor.toml`.

9. **Themed MangoHud Performance Overlay**
   - **Why**: MangoHud is installed with gaming tools but lacks a custom configuration.
   - **Action**: Create a sleek, modern, horizontal or compact corner overlay in `dotfiles/mangohud/MangoHud.conf` styled with Matugen color variables, displaying RX 7900 XT & Ryzen 5700X clocks, temps, power draw, and frametime graph.

10. **MangoWM Glassmorphism Polish (SceneFX Blur & Floating Shadows)**
    - **Why**: `dotfiles/mango/cfg/appearance.conf` contains commented-out SceneFX options.
    - **Action**: Enable `blur = 1`, `shadows = 1`, and `shadow_only_floating = 1` with fine-tuned radius and opacity for floating windows and modal overlays.

---

## 🤖 Automations in General

*Automating daily maintenance, system checks, and background tasks.*

11. **Automated Noctalia Night Light Schedule**
    - **Why**: Avoids manual toggling of night light mode when working late.
    - **Action**: Configure an automated sunset-to-sunrise schedule and color temperature curve in [`dotfiles/noctalia/settings.toml`](file:///home/tiizzel/mangoNix/dotfiles/noctalia/settings.toml).

12. **Btrfs Automated Scrub & Maintenance Timers**
    - **Why**: SSD Btrfs filesystems benefit from periodic verification to detect bit rot and keep filesystem metadata healthy.
    - **Action**: Add `services.btrfs.autoScrub = { enable = true; interval = "weekly"; };` to system configuration.

13. **Nix Flake & System Update Notification Daemon**
    - **Why**: Effortlessly know when upstream packages or flake inputs have updates available without manual terminal checks.
    - **Action**: A lightweight systemd user timer that checks git/flake inputs and posts a native Noctalia desktop notification (`noctalia msg notification-show "Updates Available" "Run 'fu' to apply."`).

14. **Dotfiles Symlink Integrity Validator**
    - **Why**: Ensures that out-of-store dotfiles symlinked by Home-Manager or custom scripts remain healthy and never point to missing paths.
    - **Action**: Add an automated validation check in [`install.sh`](file:///home/tiizzel/mangoNix/install.sh) or as a standalone CLI tool `check-dotfiles`.

---

## 🪟 Window Management, Documentation & Maintenance

15. **Window Swallowing (`swallow = true`)**
    - **Why**: Prevents inactive terminal windows from lingering on screen when launching graphical tools (e.g., editors, file managers) from Ghostty or Kitty.
    - **Action**: Add window swallow rules or compositor option in [`dotfiles/mango/cfg/rules.conf`](file:///home/tiizzel/mangoNix/dotfiles/mango/cfg/rules.conf).

16. **README Screenshots & Showcase Gallery Assets**
    - **Why**: Populates the GitHub & GitLab README showcase with 16:9 2560x1440 screenshots.
    - **Action**: Capture the 6 planned screenshots listed in [`docs/git-screenshot.md`](file:///home/tiizzel/mangoNix/docs/git-screenshot.md) and place them in [`docs/assets/`](file:///home/tiizzel/mangoNix/docs/assets/).

17. **Installer Hardening (`install.sh`)**
    - **Why**: Smooth onboarding for fresh installations or multi-monitor systems.
    - **Action**: Expand [`install.sh`](file:///home/tiizzel/mangoNix/install.sh) with disk partitioning prompts and multi-monitor display layout detection.

18. **SOPS Key Automated Generation Bootstrapping**
    - **Why**: Simplifies fresh setups when users want declarative secrets without manually running `age-keygen`.
    - **Action**: Add interactive generation of a new Age keypair when `options.var.enableSops` is selected and no existing key is provided.
