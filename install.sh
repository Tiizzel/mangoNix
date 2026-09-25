#!/usr/bin/env bash

# ==============================================================================
# mangoNix - Post-Install System Bootstrapper
# ==============================================================================
# Interactive installer to bootstrap the mangoNix configuration on a fresh NixOS
# installation. Adapts user options, hardware config, and GPU profiles.
# ==============================================================================

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Helper printing functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
question() { echo -ne "${CYAN}?${NC} $1"; }

print_header() {
    echo ""
    echo -e "${PURPLE}─── $1 ───${NC}"
}

# ------------------------------------------------------------------------------
# 1. Environment & Preflight Checks
# ------------------------------------------------------------------------------
clear
echo -e "${YELLOW}"
cat << "EOF"
                                   _   _ _      
  _ __ ___   __ _ _ __   __ _  ___| \ | (_)_  __
 | '_ ` _ \ / _` | '_ \ / _` |/ _ \  \| | \ \/ /
 | | | | | | (_| | | | | (_| | (_) | |\  | |>  < 
 |_| |_| |_|\__,_|_| |_|\__, |\___/|_| \_|_/_/\_\
                        |___/                    
EOF
echo -e "${NC}"
echo -e "${WHITE}  --- mangoNix Post-Install Bootstrapper ---${NC}"
echo -e "${CYAN}  Wayland Desktop with MangoWM, Noctalia Shell & Matugen${NC}"
echo ""

# Verify NixOS
if [ ! -f "/etc/os-release" ] || ! grep -qi "nixos" /etc/os-release; then
    error "This script is designed specifically for NixOS."
    exit 1
fi

# Verify hardware-configuration exists
if [ ! -f "/etc/nixos/hardware-configuration.nix" ]; then
    error "Could not find /etc/nixos/hardware-configuration.nix"
    echo "Please run this installer on a machine where NixOS was already installed to disk."
    exit 1
fi

# Determine target user
if [ "${EUID}" -eq 0 ]; then
    TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "tiizzel")}"
else
    TARGET_USER="${USER:-tiizzel}"
fi

TARGET_HOME="/home/${TARGET_USER}"
TARGET_DIR="${TARGET_HOME}/mangoNix"

# Sudo wrapper function
run_sudo() {
    if [ "${EUID}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Check for required tools
MISSING_TOOLS=()
for tool in git lspci; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    warning "Missing prerequisites: ${MISSING_TOOLS[*]}"
    info "Launching ephemeral nix-shell with required tools..."
    exec nix-shell -p git pciutils --run "bash $0"
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. Hardware Detection
# ------------------------------------------------------------------------------
print_header "Detecting System Hardware"

DETECTED_GPU="generic"
if lspci | grep -qi 'vga\|3d\|display'; then
    GPU_INFO=$(lspci -nn | grep -i 'vga\|3d\|display')
    if echo "$GPU_INFO" | grep -Eqi 'virtio|vmware|virtualbox|qemu|kvm|qxl'; then
        DETECTED_GPU="vm"
    elif echo "$GPU_INFO" | grep -Eq '\[10de:'; then
        DETECTED_GPU="nvidia"
    elif echo "$GPU_INFO" | grep -Eq '\[1002:'; then
        DETECTED_GPU="amd"
    elif echo "$GPU_INFO" | grep -Eq '\[8086:'; then
        DETECTED_GPU="intel"
    fi
fi
success "Detected GPU profile: ${CYAN}${DETECTED_GPU}${NC}"

# Detect system timezone
DETECTED_TIMEZONE="Europe/Berlin"
if [ -f "/etc/timezone" ]; then
    DETECTED_TIMEZONE=$(cat /etc/timezone)
elif command -v timedatectl &>/dev/null; then
    DETECTED_TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/Berlin")
fi

# ------------------------------------------------------------------------------
# 3. Interactive Configuration Prompts
# ------------------------------------------------------------------------------
print_header "Configuration Options"
echo "Press [ENTER] to accept default values shown in brackets."
echo ""

question "Username [${TARGET_USER}]: "
read -r INPUT_USER
INPUT_USER=${INPUT_USER:-"$TARGET_USER"}

# Compute display name default (capitalize first letter)
DEFAULT_NAME="$(tr '[:lower:]' '[:upper:]' <<< "${INPUT_USER:0:1}")${INPUT_USER:1}"
question "Display / Full Name [${DEFAULT_NAME}]: "
read -r INPUT_NAME
INPUT_NAME=${INPUT_NAME:-"$DEFAULT_NAME"}

question "System Hostname [nixos]: "
read -r INPUT_HOST
INPUT_HOST=${INPUT_HOST:-"nixos"}

echo ""
info "Available GPU profiles: amd, nvidia, intel, vm, generic"
question "GPU Driver Profile [${DETECTED_GPU}]: "
read -r INPUT_GPU
INPUT_GPU=${INPUT_GPU:-"$DETECTED_GPU"}

echo ""
question "Keyboard Layout [de]: "
read -r INPUT_KEYMAP
INPUT_KEYMAP=${INPUT_KEYMAP:-"de"}

question "System Timezone [${DETECTED_TIMEZONE}]: "
read -r INPUT_TIMEZONE
INPUT_TIMEZONE=${INPUT_TIMEZONE:-"$DETECTED_TIMEZONE"}

echo ""
info "SOPS Secrets: To decrypt your SSH keys and secrets automatically,"
info "you can import your Age secret key (from ~/.config/sops/age/keys.txt)."
question "Do you want to import your Age secret key now? [y/N]: "
read -r IMPORT_AGE
IMPORT_AGE=${IMPORT_AGE:-"n"}

AGE_KEY_CONTENT=""
if [[ "$IMPORT_AGE" =~ ^[Yy]$ ]]; then
    question "Paste your Age secret key (starts with AGE-SECRET-KEY-...): "
    read -r AGE_KEY_CONTENT
fi

# ------------------------------------------------------------------------------
# 4. Summary Confirmation
# ------------------------------------------------------------------------------
print_header "Installation Summary"
cat << EOF
  • Target Directory:  ${TARGET_DIR}
  • Username:          ${INPUT_USER}
  • Display Name:      ${INPUT_NAME}
  • Hostname:          ${INPUT_HOST}
  • GPU Profile:       ${INPUT_GPU}
  • Keyboard Layout:   ${INPUT_KEYMAP}
  • Timezone:          ${INPUT_TIMEZONE}
EOF
echo ""

question "Proceed with installation and build? [Y/n]: "
read -r CONFIRM
CONFIRM=${CONFIRM:-"y"}

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    warning "Installation aborted by user."
    exit 0
fi

# ------------------------------------------------------------------------------
# 5. Clone or Setup Repository
# ------------------------------------------------------------------------------
print_header "Preparing mangoNix Repository"

# If script is run directly from the repo directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
    if [ ! -d "$TARGET_DIR" ]; then
        info "Cloning mangoNix into ${TARGET_DIR}..."
        git clone https://github.com/Tiizzel/mangoNix.git "$TARGET_DIR"
    else
        info "Existing directory found at ${TARGET_DIR}."
    fi
    cd "$TARGET_DIR"
else
    info "Running directly inside ${TARGET_DIR}."
fi

# ------------------------------------------------------------------------------
# 6. Apply Hardware & User Configuration
# ------------------------------------------------------------------------------
print_header "Applying Declarative Options"

# 1. Copy hardware configuration
info "Copying /etc/nixos/hardware-configuration.nix..."
cp /etc/nixos/hardware-configuration.nix "${TARGET_DIR}/hardware-configuration.nix"
success "Hardware configuration copied."

# 2. Update modules/users/user.nix
USER_CONFIG="${TARGET_DIR}/modules/users/user.nix"
info "Configuring user module (${USER_CONFIG})..."

cat << EOF > "$USER_CONFIG"
{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    options.var = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "${INPUT_USER}";
        description = "Primary user account name";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "${INPUT_NAME}";
        description = "Primary user's real or display name";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "${INPUT_HOST}";
        description = "System hostname";
      };
      dotfilesDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/\${config.var.username}/mangoNix";
        description = "Path to the mangoNix configuration directory";
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "${INPUT_TIMEZONE}";
        description = "System timezone";
      };
      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "${INPUT_KEYMAP}";
        description = "System keyboard layout";
      };
      gpu = lib.mkOption {
        type = lib.types.enum [ "amd" "nvidia" "intel" "vm" "generic" ];
        default = "${INPUT_GPU}";
        description = "Primary GPU driver profile";
      };
    };

    config = {
      users.users.\${config.var.username} = {
        isNormalUser = true;
        description = config.var.name;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
          kdePackages.kate
        ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.\${config.var.username} = { pkgs, ... }: {
          home.stateVersion = "24.05";
          programs.home-manager.enable = true;
          imports = [
            inputs.self.modules.home.base
          ];
        };
      };
    };
  };
}
EOF
success "User module updated with custom settings."

# 3. Update MangoWM keyboard layout
MANGO_INPUT="${TARGET_DIR}/dotfiles/mango/cfg/input.conf"
if [ -f "$MANGO_INPUT" ]; then
    info "Setting MangoWM keyboard layout to '${INPUT_KEYMAP}'..."
    sed -i "s/^xkb_rules_layout = .*/xkb_rules_layout = ${INPUT_KEYMAP}/" "$MANGO_INPUT"
fi

# 4. Set up SOPS Age key if provided
if [ -n "$AGE_KEY_CONTENT" ]; then
    info "Installing SOPS Age key for user ${INPUT_USER}..."
    USER_AGE_DIR="/home/${INPUT_USER}/.config/sops/age"
    mkdir -p "$USER_AGE_DIR"
    echo "$AGE_KEY_CONTENT" > "${USER_AGE_DIR}/keys.txt"
    chmod 600 "${USER_AGE_DIR}/keys.txt"
    if [ -n "${TARGET_USER}" ] && [ "${TARGET_USER}" != "root" ]; then
        run_sudo chown -R "${TARGET_USER}:" "/home/${INPUT_USER}/.config/sops" 2>/dev/null || true
    fi
    success "Age key installed at ${USER_AGE_DIR}/keys.txt."
fi

# 5. Stage git files so Flakes recognizes new and modified files
info "Staging configuration changes in git..."
git add -A
success "All configuration files staged."

# 6. Ensure file ownership
if [ -n "${TARGET_USER}" ] && [ "${TARGET_USER}" != "root" ]; then
    run_sudo chown -R "${TARGET_USER}:" "$TARGET_DIR" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 7. Build and Switch Configuration
# ------------------------------------------------------------------------------
print_header "Building NixOS Configuration"
info "Starting system rebuild with Flakes (this may take several minutes)..."
echo ""

if run_sudo nixos-rebuild switch --flake ".#nixos" --extra-experimental-features "nix-command flakes"; then
    echo ""
    success "NixOS system build and activation completed successfully!"
else
    echo ""
    error "System build failed. Check the error messages above for details."
    exit 1
fi

# ------------------------------------------------------------------------------
# 8. Post-Install Completion
# ------------------------------------------------------------------------------
print_header "Installation Finished!"

cat << "EOF"
  ╔══════════════════════════════════════════════════════════════════╗
  ║                mangoNix Installation Complete!                  ║
  ║                                                                  ║
  ║   Keybindings Cheatsheet:                                        ║
  ║     • SUPER + Space     : Noctalia App Launcher                  ║
  ║     • SUPER + t         : Open Ghostty Terminal                  ║
  ║     • SUPER + b         : Launch Zen Browser                     ║
  ║     • SUPER + f         : Open Thunar File Manager               ║
  ║     • SUPER + q         : Close Window                           ║
  ║     • SUPER + SHIFT + c : Noctalia Control Center                ║
  ╚══════════════════════════════════════════════════════════════════╝
EOF
echo ""

question "Would you like to reboot the system now? [y/N]: "
read -r REBOOT_CONFIRM
REBOOT_CONFIRM=${REBOOT_CONFIRM:-"n"}

if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    info "Rebooting system..."
    run_sudo reboot
else
    info "Installation complete. Please reboot when convenient to load the full desktop."
fi
