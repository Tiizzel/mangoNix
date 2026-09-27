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

# Cleanup temporary files on exit
TMP_INSTALLER=""
cleanup() {
    if [ -n "$TMP_INSTALLER" ] && [ -f "$TMP_INSTALLER" ]; then
        rm -f "$TMP_INSTALLER"
    fi
}
trap cleanup EXIT INT TERM

# Helper input reader that safely handles piped stdin (curl ... | bash) and interactive tty
prompt_read() {
    local var_name="$1"
    local input_val=""
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
        # Script is running from a file on disk: stdin is safely dedicated to user input
        read -r input_val || true
    elif [ -r /dev/tty ]; then
        # Script is piped via stdin (e.g. curl ... | bash): read user input from terminal
        read -r input_val < /dev/tty || true
    else
        read -r input_val || true
    fi
    printf -v "$var_name" '%s' "$input_val"
}

# ------------------------------------------------------------------------------
# 1. Environment & Preflight Checks
# ------------------------------------------------------------------------------
clear 2>/dev/null || true
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
    TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
else
    TARGET_USER="${USER:-tiizzel}"
fi

# Fallback if target user is root or blank
if [ "$TARGET_USER" = "root" ] || [ -z "$TARGET_USER" ]; then
    FIRST_USER=$(find /home -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | head -n 1 || true)
    TARGET_USER="${FIRST_USER:-tiizzel}"
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6 || true)"
TARGET_HOME="${TARGET_HOME:-/home/${TARGET_USER}}"
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
MISSING_PKGS=()
if ! command -v git &>/dev/null; then
    MISSING_PKGS+=("git")
fi
if ! command -v lspci &>/dev/null; then
    MISSING_PKGS+=("pciutils")
fi

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    warning "Missing prerequisites: ${MISSING_PKGS[*]}"
    info "Launching ephemeral nix-shell with required tools..."
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
        SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || readlink -f "${BASH_SOURCE[0]}")"
        exec nix-shell -p "${MISSING_PKGS[@]}" --run "bash \"$SCRIPT_PATH\" \"$@\""
    else
        TMP_INSTALLER="$(mktemp /tmp/mangonix-installer.XXXXXX.sh)"
        info "Fetching installer script to ${TMP_INSTALLER}..."
        curl -fsSL "https://raw.githubusercontent.com/Tiizzel/mangoNix/main/install.sh" > "$TMP_INSTALLER"
        chmod +x "$TMP_INSTALLER"
        exec nix-shell -p "${MISSING_PKGS[@]}" --run "bash \"$TMP_INSTALLER\" \"$@\""
    fi
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. Hardware Detection
# ------------------------------------------------------------------------------
print_header "Detecting System Hardware"

DETECTED_GPU="generic"
if command -v lspci &>/dev/null; then
    GPU_INFO=$(lspci -nn 2>/dev/null | grep -i 'vga\|3d\|display' || true)
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

# Fallback to sysfs DRM device vendor if lspci did not detect anything or is missing
if [ "$DETECTED_GPU" = "generic" ] && [ -d "/sys/class/drm" ]; then
    for vfile in /sys/class/drm/card*/device/vendor; do
        if [ -r "$vfile" ]; then
            VENDOR=$(cat "$vfile" 2>/dev/null || true)
            case "$VENDOR" in
                0x1002|0x1002*) DETECTED_GPU="amd"; break ;;
                0x10de|0x10de*) DETECTED_GPU="nvidia"; break ;;
                0x8086|0x8086*) DETECTED_GPU="intel"; break ;;
                0x1af4|0x15ad|0x80ee|0x1b36*) DETECTED_GPU="vm"; break ;;
            esac
        fi
    done
fi
success "Detected GPU profile: ${CYAN}${DETECTED_GPU}${NC}"

# Detect system timezone
DETECTED_TIMEZONE="Europe/Berlin"
if [ -f "/etc/timezone" ]; then
    DETECTED_TIMEZONE=$(cat /etc/timezone 2>/dev/null || echo "Europe/Berlin")
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
prompt_read INPUT_USER
INPUT_USER=${INPUT_USER:-"$TARGET_USER"}

# Recompute target paths based on chosen username
TARGET_HOME="/home/${INPUT_USER}"
TARGET_DIR="${TARGET_HOME}/mangoNix"

# Compute display name default (capitalize first letter)
DEFAULT_NAME="$(tr '[:lower:]' '[:upper:]' <<< "${INPUT_USER:0:1}")${INPUT_USER:1}"
question "Display / Full Name [${DEFAULT_NAME}]: "
prompt_read INPUT_NAME
INPUT_NAME=${INPUT_NAME:-"$DEFAULT_NAME"}

question "System Hostname [nixos]: "
prompt_read INPUT_HOST
INPUT_HOST=${INPUT_HOST:-"nixos"}

echo ""
info "Available GPU profiles: amd, nvidia, intel, vm, generic"
question "GPU Driver Profile [${DETECTED_GPU}]: "
prompt_read INPUT_GPU
INPUT_GPU=${INPUT_GPU:-"$DETECTED_GPU"}

echo ""
question "Keyboard Layout [de]: "
prompt_read INPUT_KEYMAP
INPUT_KEYMAP=${INPUT_KEYMAP:-"de"}

question "System Timezone [${DETECTED_TIMEZONE}]: "
prompt_read INPUT_TIMEZONE
INPUT_TIMEZONE=${INPUT_TIMEZONE:-"$DETECTED_TIMEZONE"}

echo ""
info "SOPS Secrets: If you are the owner, import your Age key to decrypt your SSH keys."
info "If you are a new user or do not have the Age key, choose 'No' to disable SOPS."
question "Enable SOPS secrets management? [y/N]: "
prompt_read IMPORT_AGE
IMPORT_AGE=${IMPORT_AGE:-"n"}

INPUT_SOPS="false"
AGE_KEY_CONTENT=""
if [[ "$IMPORT_AGE" =~ ^[Yy]$ ]]; then
    INPUT_SOPS="true"
    question "Paste your Age secret key (starts with AGE-SECRET-KEY-...): "
    prompt_read AGE_KEY_CONTENT
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
  • SOPS Secrets:      ${INPUT_SOPS}
EOF
echo ""

question "Proceed with installation and build? [Y/n]: "
prompt_read CONFIRM
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
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -z "$SCRIPT_DIR" ] || [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
    if [ ! -d "$TARGET_DIR" ]; then
        info "Cloning mangoNix into ${TARGET_DIR}..."
        run_sudo mkdir -p "$(dirname "$TARGET_DIR")"
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

# 1. Setup host directory and copy hardware configuration
HOST_DIR="${TARGET_DIR}/hosts/${INPUT_HOST}"
info "Configuring host directory (${HOST_DIR})..."
run_sudo mkdir -p "$HOST_DIR"

info "Copying /etc/nixos/hardware-configuration.nix to ${HOST_DIR}/hardware-configuration.nix..."
run_sudo cp /etc/nixos/hardware-configuration.nix "${HOST_DIR}/hardware-configuration.nix"
run_sudo chmod 644 "${HOST_DIR}/hardware-configuration.nix"

# Create host-packages.nix if not present
if [ ! -f "${HOST_DIR}/host-packages.nix" ]; then
    cat << 'EOF' > "${HOST_DIR}/host-packages.nix"
{ pkgs, ... }: {
  # Packages installed specifically on this host
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here, for example:
    # lact             # GPU control / overclocking
    # nvtopPackages.amd
  ];
}
EOF
fi

# Create variables.nix with configured options
info "Generating host variables (${HOST_DIR}/variables.nix)..."
cat << EOF > "${HOST_DIR}/variables.nix"
{ config, ... }: {
  var = {
    # Primary user account name
    username = "${INPUT_USER}";

    # Primary user real or display name
    name = "${INPUT_NAME}";

    # System hostname
    hostname = "${INPUT_HOST}";

    # Path to the mangoNix configuration directory
    dotfilesDir = "/home/\${config.var.username}/mangoNix";

    # System timezone
    timezone = "${INPUT_TIMEZONE}";

    # System keyboard layout
    keyboardLayout = "${INPUT_KEYMAP}";

    # Primary GPU driver profile: "amd" | "nvidia" | "intel" | "vm" | "generic"
    gpu = "${INPUT_GPU}";

    # Enable SOPS encrypted secrets management
    enableSops = ${INPUT_SOPS};
  };
}
EOF

# Create default.nix entrypoint if not present
if [ ! -f "${HOST_DIR}/default.nix" ]; then
    cat << 'EOF' > "${HOST_DIR}/default.nix"
{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix
    ./variables.nix
  ];

  # Host-specific configuration and option overrides can be placed here.
}
EOF
fi
success "Host configuration established at ${HOST_DIR}."

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
      enableSops = lib.mkOption {
        type = lib.types.bool;
        default = ${INPUT_SOPS};
        description = "Enable SOPS encrypted secrets management";
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

# 4. Set up SOPS Age key or fallback SSH key
if [ "$INPUT_SOPS" = "true" ] && [ -n "$AGE_KEY_CONTENT" ]; then
    info "Installing SOPS Age key for user ${INPUT_USER}..."
    USER_AGE_DIR="${TARGET_HOME}/.config/sops/age"
    run_sudo mkdir -p "$USER_AGE_DIR"
    echo "$AGE_KEY_CONTENT" | run_sudo tee "${USER_AGE_DIR}/keys.txt" > /dev/null
    run_sudo chmod 600 "${USER_AGE_DIR}/keys.txt"
    if id "${INPUT_USER}" &>/dev/null; then
        run_sudo chown -R "${INPUT_USER}:" "${TARGET_HOME}/.config/sops" 2>/dev/null || true
    fi
    success "Age key installed at ${USER_AGE_DIR}/keys.txt."
elif [ "$INPUT_SOPS" = "false" ]; then
    USER_SSH_DIR="${TARGET_HOME}/.ssh"
    if [ ! -f "${USER_SSH_DIR}/id_ed25519" ]; then
        info "Generating a fresh SSH key for ${INPUT_USER}..."
        run_sudo mkdir -p "$USER_SSH_DIR"
        run_sudo ssh-keygen -t ed25519 -C "${INPUT_USER}@${INPUT_HOST}" -f "${USER_SSH_DIR}/id_ed25519" -N ""
        run_sudo chmod 700 "$USER_SSH_DIR"
        run_sudo chmod 600 "${USER_SSH_DIR}/id_ed25519"
        run_sudo chmod 644 "${USER_SSH_DIR}/id_ed25519.pub"
        if id "${INPUT_USER}" &>/dev/null; then
            run_sudo chown -R "${INPUT_USER}:" "$USER_SSH_DIR" 2>/dev/null || true
        fi
        success "New SSH key generated at ${USER_SSH_DIR}/id_ed25519."
    fi
fi

# 5. Stage git files so Flakes recognizes new and modified files
info "Staging configuration changes in git..."
git add -A
success "All configuration files staged."

# 6. Ensure repo directory ownership
if id "${INPUT_USER}" &>/dev/null; then
    run_sudo chown -R "${INPUT_USER}:" "$TARGET_DIR" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 7. Build and Switch Configuration
# ------------------------------------------------------------------------------
print_header "Building NixOS Configuration"
info "Starting system rebuild with Flakes (this may take several minutes)..."
echo ""

if run_sudo env NIX_CONFIG="extra-experimental-features = nix-command flakes" nixos-rebuild switch --flake ".#${INPUT_HOST}" --option extra-experimental-features "nix-command flakes"; then
    echo ""
    success "NixOS system build and activation completed successfully!"

    # Ensure target user home directory permissions
    if id "${INPUT_USER}" &>/dev/null; then
        run_sudo chown -R "${INPUT_USER}:" "$TARGET_HOME" 2>/dev/null || true
    fi

    # If SOPS is enabled, configure git remotes to use SSH (GitHub & GitLab dual push)
    if [ "$INPUT_SOPS" = "true" ]; then
        info "Configuring git remotes to use SSH (GitHub & GitLab)..."
        (
            cd "$TARGET_DIR" || exit 0
            git remote set-url origin git@github.com:Tiizzel/mangoNix.git 2>/dev/null || true
            git remote set-url --add --push origin git@github.com:Tiizzel/mangoNix.git 2>/dev/null || true
            git remote set-url --add --push origin git@gitlab.com:Tiizzel/mangonix.git 2>/dev/null || true
            git remote add github git@github.com:Tiizzel/mangoNix.git 2>/dev/null || git remote set-url github git@github.com:Tiizzel/mangoNix.git 2>/dev/null || true
            git remote add gitlab git@gitlab.com:Tiizzel/mangonix.git 2>/dev/null || git remote set-url gitlab git@gitlab.com:Tiizzel/mangonix.git 2>/dev/null || true
            git remote add all git@github.com:Tiizzel/mangoNix.git 2>/dev/null || true
            git remote set-url --add --push all git@github.com:Tiizzel/mangoNix.git 2>/dev/null || true
            git remote set-url --add --push all git@gitlab.com:Tiizzel/mangonix.git 2>/dev/null || true
        )
        if [ -f "${TARGET_HOME}/.ssh/id_ed25519" ]; then
            ssh-keygen -y -f "${TARGET_HOME}/.ssh/id_ed25519" > "${TARGET_HOME}/.ssh/id_ed25519.pub" 2>/dev/null || true
            chmod 644 "${TARGET_HOME}/.ssh/id_ed25519.pub" 2>/dev/null || true
            if id "${INPUT_USER}" &>/dev/null; then
                run_sudo chown "${INPUT_USER}:" "${TARGET_HOME}/.ssh/id_ed25519.pub" 2>/dev/null || true
            fi
        fi
    fi
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
prompt_read REBOOT_CONFIRM
REBOOT_CONFIRM=${REBOOT_CONFIRM:-"n"}

if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    info "Rebooting system..."
    run_sudo reboot
else
    info "Installation complete. Please reboot when convenient to load the full desktop."
fi
