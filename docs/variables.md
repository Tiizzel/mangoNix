# Host Variables & Configuration Guide

This document explains how host-specific variables work in `mangoNix`, lists currently implemented options in [`hosts/<hostname>/variables.nix`](file:///home/tiizzel/mangoNix/hosts/nixos/variables.nix), and outlines planned variable modules for displays, hardware peripherals, feature stacks, and theming.

---

## 1. Architecture Overview

In `mangoNix`, every machine in the `hosts/` folder defines its identity and hardware characteristics in its own `variables.nix`.
These options are registered under `options.var` in [`modules/users/user.nix`](file:///home/tiizzel/mangoNix/modules/users/user.nix) and consumed across NixOS modules (`config.var.<name>`) and Home Manager modules (`osConfig.var.<name>`).

```
hosts/<hostname>/variables.nix  ──>  options.var  ──>  NixOS modules (config.var.*)
                                                   └──>  Home Manager (osConfig.var.*)
```

---

## 2. Currently Implemented Variables

| Variable | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `username` | `str` | `"tiizzel"` | Primary user account login name |
| `name` | `str` | `"Tiizzel"` | Display/GECOS name of user |
| `hostname` | `str` | `"nixos"` | Machine hostname |
| `dotfilesDir` | `str` | `"/home/${var.username}/mangoNix"` | Absolute path to mangoNix repo |
| `timezone` | `str` | `"Europe/Berlin"` | System timezone |
| `keyboardLayout` | `str` | `"de"` | X11 / Wayland keyboard layout |
| `gpu` | `enum` | `"amd"` | Primary GPU profile (`"amd"`, `"nvidia"`, `"intel"`, `"vm"`, `"generic"`) |
| `enableSops` | `bool` | `true` | Enable SOPS secrets decryption |
| **`gitUsername`** | `str` | `config.var.name` | User name for Git commits |
| **`gitEmail`** | `str` | `"adamdominik1996@gmail.com"` | Email address for Git commits |
| **`kernel`** | `enum` | `"cachyos-bore"` | Kernel variant: `"cachyos-bore"`, `"zen"`, `"latest"`, `"default"` |
| **`bootloader`** | `enum` | `"grub"` | Bootloader: `"grub"` (themed) or `"systemd-boot"` |
| **`monitorRules`** | `listOf str` | `[ "name:DP-1, ..." ]` | List of raw MangoWM `monitorrule` definitions |

---

## 3. How Host-Specific Monitors Work

In `mangoNix`, the dotfiles directory `dotfiles/mango` is symlinked out-of-store. To allow host-specific monitor configurations without editing git-tracked dotfiles:

1. **`hosts/<hostname>/variables.nix`**: Define your raw monitor rule strings:
   ```nix
   var.monitorRules = [
     "name:DP-1, width:5120, height:1440, refresh:240, x:0, y:0, rr:0, vrr:0, hdr:1, hdr_force:1, hdr_min_lum: 0.05, hdr_max_lum: 800"
   ];
   ```
2. **`modules/sessions/mangowm.nix`**: Home Manager writes `dotfiles/mango/cfg/mango-monitors.conf` containing the rendered `monitorrule = ...` lines (ignored in `.gitignore`).
3. **`dotfiles/mango/config.conf`**: Sourced with `source-optional = ./cfg/mango-monitors.conf`, seamlessly fitting alongside all other modular configs in `./cfg/`.

---

## 4. Planned Variable Options (Roadmap)

---

### Option 4: Hardware & Peripherals

Allows enabling or disabling hardware-specific services depending on whether the machine has RGB lighting, custom keyboards, or Bluetooth.

```nix
var = {
  # RGB lighting control daemon
  enableOpenRgb = true;

  # Wooting analog keyboard support (udev rules + Wootility)
  enableWooting = true;

  # Bluetooth daemon and audio profiles
  enableBluetooth = true;

  # Audio backend: "pipewire" or "pulseaudio"
  audioBackend = "pipewire";
};
```

#### Nix Module Implementation Plan:
- `enableOpenRgb`: Controls `services.hardware.openrgb.enable = config.var.enableOpenRgb;` and installs `openrgb`.
- `enableWooting`: Controls `hardware.wooting.enable = config.var.enableWooting;` and installs `wootility`.
- `enableBluetooth`: Controls `hardware.bluetooth.enable` and `services.blueman.enable`.

---

### Option 5: Feature Toggles & App Bundles

Different machines (e.g. desktop gaming rig vs. lightweight laptop vs. headless server) require different sets of heavy software.

```nix
var = {
  # Steam, GameMode, MangoHud, Proton GE, gamescope
  enableGaming = true;

  # Fallback desktop environment (KDE Plasma) alongside MangoWM
  enablePlasma = false;

  # Developer environment (Docker, Podman, extra toolchains)
  enableContainers = true;
  containerBackend = "docker"; # "docker" | "podman"

  # Virtualization (QEMU/KVM, libvirt, virt-manager)
  enableVirt = false;
};
```

#### Nix Module Implementation Plan:
- Wrap `modules/programs/steam.nix` in `lib.mkIf config.var.enableGaming { ... }`.
- Conditionally enable `services.desktopManager.plasma6.enable = config.var.enablePlasma;`.
- Conditionally enable `virtualisation.docker.enable = config.var.enableContainers && config.var.containerBackend == "docker";`.

---

### Option 6: Theming, Locales & Terminal Defaults

Allows personalizing the desktop appearance and defaults per host (e.g., higher scaling or distinct terminal/wallpaper on a laptop).

```nix
var = {
  # Default system locale
  locale = "de_DE.UTF-8";

  # Preferred terminal emulator: "ghostty" | "kitty"
  defaultTerminal = "ghostty";

  # Default GTK/Qt theme palette accent
  themeAccent = "orange"; # Matches mango branding

  # Custom wallpaper filename located in dotfiles/wallpapers/
  wallpaper = "mango-dark.png";
};
```

#### Nix Module Implementation Plan:
- `i18n.defaultLocale = config.var.locale;`.
- Set default terminal in `environment.variables.TERMINAL = config.var.defaultTerminal;` and MangoWM `scripts/launch-terminal.sh`.

---

## 4. Multi-Host Comparison Example

Here is how different machine configurations look side-by-side using these variables:

| Setting | Desktop (`hosts/nixos/variables.nix`) | Laptop (`hosts/thinkpad/variables.nix`) |
| :--- | :--- | :--- |
| `hostname` | `"nixos"` | `"thinkpad"` |
| `gpu` | `"amd"` | `"intel"` |
| `kernel` | `"cachyos-bore"` | `"zen"` |
| `bootloader` | `"grub"` | `"systemd-boot"` |
| `enableGaming` | `true` | `false` |
| `enableOpenRgb` | `true` | `false` |
| `enableWooting` | `true` | `false` |
| `enableBluetooth`| `true` | `true` |
