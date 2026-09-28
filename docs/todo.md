# 📋 mangoNix TODO & System Improvement Roadmap

This roadmap tracks completed milestones and organizes pending system tasks, compositor improvements, gaming/performance tuning, theming hooks, and automations.

---

## 🚀 Recently Completed Milestones

- [x] **Mesa / RADV Graphics Pipeline & Memory Tuning:** Configured 8GB shader cache (`MESA_SHADER_CACHE_MAX_SIZE = "8G"`), enabled GPL fast-linking and Smart Access Memory (`RADV_PERFTEST = "gpl,sam"`), and disabled split-lock mitigation (`split_lock_mitigate=0`) in [`modules/hardware/drivers.nix`](file:///home/tiizzel/mangoNix/modules/hardware/drivers.nix).
- [x] **Proton Virtual Memory Max Map Count:** Configured `vm.max_map_count = 2147483642` in [`modules/system/memory.nix`](file:///home/tiizzel/mangoNix/modules/system/memory.nix) preventing memory exhaustion crashes in heavy modern titles (Steam Proton, Star Citizen, DayZ, CS2).
- [x] **Declarative Secondary NVMe Storage Mount:** Created dedicated [`hosts/nixos/drives.nix`](file:///home/tiizzel/mangoNix/hosts/nixos/drives.nix) mounting Samsung SSD 970 EVO 1TB at `/mnt/games` with `noatime` and `systemd.tmpfiles.rules` ownership permissions, preserving clean isolation from `hardware-configuration.nix`.
- [x] **HUD Fastfetch & Native Matugen Dynamic Theming:** Restructured Fastfetch into a HUD layout with multi-category telemetry, dedicated Root and Games disk metrics, and a native Matugen template ([`dotfiles/matugen/templates/fastfetch.jsonc`](file:///home/tiizzel/mangoNix/dotfiles/matugen/templates/fastfetch.jsonc)) generating full 6-arm alternating snowflake palettes directly on wallpaper sync.
- [x] **Multi-Host Configuration & Variables Architecture:** Decoupled host identities into [`hosts/<hostname>/variables.nix`](file:///home/tiizzel/mangoNix/hosts/nixos/variables.nix) (`gitUsername`, `gitEmail`, `kernel`, `bootloader`, `monitorRules`), documented in [`docs/variables.md`](file:///home/tiizzel/mangoNix/docs/variables.md).
- [x] **Variable Refresh Rate (VRR / FreeSync) in MangoWM:** Configured `vrr:1` on `DP-1` (5120x1440 @ 240Hz) via host `monitorRules` in [`hosts/nixos/variables.nix`](file:///home/tiizzel/mangoNix/hosts/nixos/variables.nix) generating to `dotfiles/mango/cfg/mango-monitors.conf`.
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
- [x] **Terminal Window Swallowing (`isterm:1`):** Configured window swallowing rules in [`dotfiles/mango/cfg/rules.conf`](file:///home/tiizzel/mangoNix/dotfiles/mango/cfg/rules.conf) for Ghostty (`com.mitchellh.ghostty`) and Kitty (`kitty`), allowing child GUI applications launched from the terminal to temporarily swallow the inactive terminal window and automatically restore it upon exit.

---

## 🤖 Automations & System Integrity

*Automating daily maintenance, system checks, and background tasks.*

1. **Nix Flake & System Update Notification Daemon**
   - **Why**: Effortlessly know when upstream packages or flake inputs have updates available without manual terminal checks.
   - **Action**: A lightweight systemd user timer that checks git/flake inputs and posts a native Noctalia desktop notification (`noctalia msg notification-show "Updates Available" "Run 'fu' to apply."`).

2. **Dotfiles Symlink Integrity Validator**
   - **Why**: Out-of-store symlinks in [`modules/system/dotfiles.nix`](file:///home/tiizzel/mangoNix/modules/system/dotfiles.nix) can occasionally break if dotfile directories are moved or renamed.
   - **Action**: Add a lightweight preflight or shell alias (`dots-check`) that verifies all symlinks defined in `dotfiles.nix` exist and resolve to valid targets.

---

## 🪟 Window Management, Documentation & Maintenance

3. **README Screenshots & Showcase Gallery Assets**
   - **Why**: Populates the GitHub & GitLab README showcase with 16:9 2560x1440 screenshots.
   - **Action**: Capture the 6 planned screenshots listed in [`docs/git-screenshot.md`](file:///home/tiizzel/mangoNix/docs/git-screenshot.md) and place them in [`docs/assets/`](file:///home/tiizzel/mangoNix/docs/assets/).

4. **Installer Hardening (`install.sh`)**
   - **Why**: Smooth onboarding for fresh installations or multi-monitor systems.
   - **Action**: Expand [`install.sh`](file:///home/tiizzel/mangoNix/install.sh) with disk partitioning prompts and multi-monitor display layout detection.

5. **SOPS Key Automated Generation Bootstrapping**
   - **Why**: Simplifies fresh setups when users want declarative secrets without manually running `age-keygen`.
   - **Action**: Add interactive generation of a new Age keypair when `options.var.enableSops` is selected and no existing key is provided.

---

## 🎨 Visual Polish & Ricing

*Inspired by r/unixporn top posts and trending Wayland rices.*

7. **Animated Wallpaper Pipeline (mpvpaper / awww)**
   - **Why**: Static wallpapers are yesterday — the top r/unixporn posts in 2025 all use subtle animated loops (cinemagraphs, particle effects, living landscapes). A video wallpaper that reacts to your Matugen palette would be unique.
   - **Action**: Package `mpvpaper` (for video loops) or `awww` (for smooth GIF transitions) in a new `modules/theming/wallpaper.nix`. Wire up a Matugen hook that triggers `awww img` on wallpaper change so transitions are buttery smooth instead of hard-cutting. Add keybind `SUPER + W` to cycle through a curated wallpaper directory.

8. **wlogout Power Menu with Custom Matugen CSS**
   - **Why**: Default logout/shutdown dialogs look generic. A styled `wlogout` with glassmorphism panels and wallpaper-synced accent colors is a staple of polished rices.
   - **Action**: Add `wlogout` package and create a `dotfiles/wlogout/` config with Matugen-templated `style.css` (blur backdrop, rounded buttons with `{{colors.primary}}` accents). Bind to `SUPER + Escape` in MangoWM keybinds.

9. **Dynamic Lockscreen (hyprlock / swaylock-effects)**
   - **Why**: A lockscreen that pulls the current wallpaper, applies a frosted blur, and shows a minimal clock with Matugen accent colors looks premium — and it's functional security.
   - **Action**: Configure `swaylock-effects` (since MangoWM is wlroots-based) with `--screenshots --effect-blur 20x5 --clock --indicator` and a Matugen-templated color config. Wire to `swayidle` for auto-lock after 5 min idle + DPMS off after 10 min.

10. **Consistent GTK / Qt / Electron App Theming**
    - **Why**: Even with Matugen handling your shell, GTK apps (Thunar, GIMP) and Qt apps (KDE tools) can look jarring if they don't follow the wallpaper palette.
    - **Action**: Extend [`modules/theming/gtk.nix`](file:///home/tiizzel/mangoNix/modules/theming/gtk.nix) to generate `gtk-3.0/gtk.css` and `gtk-4.0/gtk.css` overrides from Matugen colors. Add a `modules/theming/qt.nix` using `qt5ct`/`qt6ct` with a Matugen-synced Kvantum theme for Qt consistency.

---

## 🎮 Gaming Enhancements

*Squeezing every frame and every QoL improvement out of the RX 7900 XT.*

11. **MangoHud Per-Game Profiles via Home Manager**
    - **Why**: Competitive shooters (CS2, Valorant via Proton) benefit from a minimal HUD (just FPS + frametime), while open-world games (Hogwarts Legacy, Star Citizen) benefit from a full telemetry overlay (GPU temp, VRAM, CPU load).
    - **Action**: Create `dotfiles/MangoHud/MangoHud.conf` (global default) and per-game overrides (e.g., `wine-cs2.conf` with `fps_only` layout). Symlink via `dotfiles.nix` and document the naming convention.

12. **GameMode System Integration**
    - **Why**: `gamemode` auto-tunes CPU governor, I/O priority, GPU clocks, and kernel scheduler when a game launches — free performance with zero per-game config.
    - **Action**: Enable `programs.gamemode.enable = true` in a new `modules/gaming/gamemode.nix`. Add a custom `gamemode.ini` with an `end` script that triggers a Noctalia notification ("GameMode deactivated — returning to balanced profile").

13. **Gamescope HDR Session Mode Refinement**
    - **Why**: The G9 (5120x1440 @ 240Hz HDR) + RX 7900 XT is the ideal combo for gamescope's `--hdr-enabled --hdr-itm-enable` pipeline, giving per-game HDR tonemapping without compositor overhead.
    - **Action**: Refine `programs.gamescope.args` in [`modules/gaming/steam.nix`](file:///home/tiizzel/mangoNix/modules/gaming/steam.nix) to include `--hdr-enabled --adaptive-sync --force-grab-cursor`. Add Steam launch option presets to docs.

14. **Replay Buffer / Instant Replay (GPU Screen Recorder)**
    - **Why**: NVIDIA ShadowPlay equivalent for AMD — continuously record the last 60s and save highlights with a hotkey, zero performance impact via VAAPI hardware encoding.
    - **Action**: Package `gpu-screen-recorder` and configure a systemd user service with `--replay-buffer 60`. Bind `SUPER + Shift + R` to save the buffer. Store clips in `/mnt/games/Replays/`.

---

## 🔧 Infrastructure & Automation (Expanded)

*Going beyond basics — declarative everything.*

15. **Btrfs Automated Snapshots (btrbk)**
    - **Why**: Before every `nixos-rebuild switch`, automatically snapshot your system subvolume. If a rebuild goes catastrophically wrong (kernel panic, driver regression), roll back in seconds from GRUB.
    - **Action**: Add `btrbk` or `snapper` with a pre-rebuild hook in `nh` or a wrapper script. Retain last 5 snapshots, auto-prune older ones. Configure in a new `modules/system/snapshots.nix`.

16. **Declarative Disk Layout (Disko)**
    - **Why**: Your partition layout should be code, not tribal knowledge. `disko` lets you define partitions, subvolumes, and mount points in Nix — making fresh installs or disk migrations a single `disko --mode disko` command.
    - **Action**: Create a `hosts/nixos/disko.nix` that mirrors your current partition layout (EFI, root, `/mnt/games` NVMe). Future-proofs `install.sh` to just call disko.

17. **Systemd Boot Entry Cleanup & Generation Limiting**
    - **Why**: After weeks of rebuilds, dozens of old generations clutter the boot menu. Explicit limits keep the bootloader fast and clean.
    - **Action**: Add `boot.loader.systemd-boot.configurationLimit = 10` in [`modules/system/boot.nix`](file:///home/tiizzel/mangoNix/modules/system/boot.nix) so only the 10 most recent generations are shown.

18. **Flake Input Auto-Update CI (GitHub Actions)**
    - **Why**: Keep your flake inputs fresh without manually running `nix flake update`. A weekly GitHub Action that opens a PR with the updated `flake.lock` lets you review before merging.
    - **Action**: Add `.github/workflows/update-flake.yml` with `nix flake update`, auto-commit, and PR creation. Optional: add `nix flake check` as a CI gate.

---

## 🧪 Experimental / Horizon

*Ambitious ideas to explore when the core is rock-solid.*

19. **NixOS Impermanence (Ephemeral Root / "Erase Your Darlings")**
    - **Why**: The ultimate in declarative purity — your root filesystem lives on `tmpfs` and is wiped every reboot. Only explicitly persisted state survives. Forces you to declare everything, catches config drift, and feels like a fresh install every boot.
    - **Action**: Research feasibility with current Btrfs layout. Start with a test VM before migrating the main host. Use `nix-community/impermanence` module.

20. **Niri Scrolling Compositor (Alternative WM Session)**
    - **Why**: Niri's infinite-scroll tiling is genuinely novel — instead of grid-based workspaces, windows tile in a single horizontal strip you scroll through. Perfect for ultrawide (5120px). Many r/unixporn top posts now feature Niri.
    - **Action**: Add as an optional session in `modules/sessions/niri.nix` alongside MangoWM and Plasma. Share the same Matugen/Noctalia theming pipeline.

21. **Wallpaper-Reactive OpenRGB Ambient Lighting**
    - **Why**: Go beyond static keyboard colors — sample dominant colors from the wallpaper in real-time and push them to all OpenRGB devices (keyboard, case fans, GPU backplate) for a true ambient lighting effect synced to your desktop.
    - **Action**: Extend [`modules/theming/openrgb.nix`](file:///home/tiizzel/mangoNix/modules/theming/openrgb.nix) with a Matugen post-hook that extracts the 3 dominant wallpaper colors and maps them to OpenRGB zones. Could also react to audio visualizer data for gaming sessions.

22. **Declarative Firefox Userchrome CSS (Matugen-Synced)**
    - **Why**: Firefox's UI chrome (tabs, toolbar, sidebar) sticks out like a sore thumb in a fully themed desktop. A Matugen-templated `userChrome.css` brings it in line with the rest of your palette automatically on every wallpaper change.
    - **Action**: Create `dotfiles/matugen/templates/userChrome.css` and symlink via Home Manager into the Firefox profile. Restyle tab bar, URL bar, and sidebar panel with Matugen `{{colors.*}}` tokens.

23. **Terminal Sixel / Kitty Image Protocol in Fastfetch**
    - **Why**: Instead of the ASCII nixos logo, render your actual `face.jpg` or a custom PNG logo directly in the terminal using Kitty's image protocol or Ghostty's Sixel support. Much cleaner look.
    - **Action**: Update the Fastfetch Matugen template to use `"type": "kitty-direct"` or `"type": "sixel"` with `"source": "~/mangoNix/docs/assets/face.jpg"` as the logo. Test in both Ghostty and Kitty.

---

## ⏸️ Deferred / Blocked

- **MangoWM Glassmorphism (SceneFX Blur & Floating Shadows):** *Blocked* — SceneFX currently does not support HDR outputs (`hdr:1, hdr_force:1`), causing rendering issues on the Samsung Odyssey G9.
