#!/usr/bin/env bash
# update-core.sh - Lightweight updater for OpenClaw on Android (existing installations)
# Called by update.sh (thin wrapper) or oaupdate command
# Derived from: https://github.com/AidanPark/openclaw-android
# License: MIT
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

REPO_BASE="https://raw.githubusercontent.com/Vamsiindugu/Openclaw-on-Android/main"
OPENCLAW_DIR="$HOME/.openclaw-android"
OA_VERSION="1.2.1"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  OpenClaw on Android - Updater v${OA_VERSION}${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

step() {
    echo ""
    echo -e "${BOLD}[$1/9] $2${NC}"
    echo "----------------------------------------"
}

# ─────────────────────────────────────────────
step 1 "Pre-flight Check"

# Check Termux
if [ -z "${PREFIX:-}" ]; then
    echo -e "${RED}[FAIL]${NC} Not running in Termux (\$PREFIX not set)"
    exit 1
fi
echo -e "${GREEN}[OK]${NC}   Termux detected"

# Check existing OpenClaw installation
if ! command -v openclaw &>/dev/null; then
    echo -e "${RED}[FAIL]${NC} openclaw command not found"
    echo "       Run the full installer first:"
    echo "       curl -sL https://raw.githubusercontent.com/Vamsiindugu/Openclaw-on-Android/main/install.sh | bash"
    exit 1
fi
echo -e "${GREEN}[OK]${NC}   openclaw $(openclaw --version 2>/dev/null || echo "installed")"

# Create directory
mkdir -p "$OPENCLAW_DIR"

# Check curl
if ! command -v curl &>/dev/null; then
    echo -e "${RED}[FAIL]${NC} curl not found. Install it with: pkg install curl"
    exit 1
fi
echo -e "${GREEN}[OK]${NC}   curl available"

# Check Phantom Process Killer (Android 12+, API 31+)
SDK_INT=$(getprop ro.build.version.sdk 2>/dev/null || echo "0")
if [ "$SDK_INT" -ge 31 ] 2>/dev/null; then
    PPK_VALUE=$(/system/bin/settings get global settings_enable_monitor_phantom_procs 2>/dev/null || echo "")
    if [ "$PPK_VALUE" = "false" ]; then
        echo -e "${GREEN}[OK]${NC}   Phantom Process Killer disabled"
    else
        echo -e "${YELLOW}[WARN]${NC} Phantom Process Killer is active"
        echo "       Background processes may be killed by Android."
        echo "       To disable:"
        echo "       adb shell \"settings put global settings_enable_monitor_phantom_procs false\""
    fi
fi

# ─────────────────────────────────────────────
step 2 "Installing New Packages"

# Install ttyd if not already installed
if command -v ttyd &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}   ttyd already installed"
else
    echo "Installing ttyd..."
    if pkg install -y ttyd 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC}   ttyd installed"
    else
        echo -e "${YELLOW}[WARN]${NC} Failed to install ttyd (non-critical)"
    fi
fi

# Install dufs if not already installed
if command -v dufs &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}   dufs already installed"
else
    echo "Installing dufs..."
    if pkg install -y dufs 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC}   dufs installed"
    else
        echo -e "${YELLOW}[WARN]${NC} Failed to install dufs (non-critical)"
    fi
fi

# Install android-tools (adb) if not already installed
if command -v adb &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}   android-tools already installed"
else
    echo "Installing android-tools..."
    if pkg install -y android-tools 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC}   android-tools installed"
    else
        echo -e "${YELLOW}[WARN]${NC} Failed to install android-tools (non-critical)"
    fi
fi

# ─────────────────────────────────────────────
step 3 "Updating Scripts and Patches"

# Download and apply patches
PATCHES_DIR="$OPENCLAW_DIR/patches"
mkdir -p "$PATCHES_DIR"

for patch_file in bionic-compat.js termux-compat.h spawn.h argon2-stub.js; do
    echo "  Downloading $patch_file..."
    if curl -sfL "$REPO_BASE/patches/$patch_file" -o "$PATCHES_DIR/$patch_file" 2>/dev/null; then
        echo -e "  ${GREEN}[OK]${NC}   $patch_file"
    else
        echo -e "  ${YELLOW}[WARN]${NC} Failed to download $patch_file"
    fi
done

# Install spawn.h to PREFIX/include
if [ -f "$PATCHES_DIR/spawn.h" ]; then
    mkdir -p "$PREFIX/include"
    cp "$PATCHES_DIR/spawn.h" "$PREFIX/include/spawn.h"
    echo -e "${GREEN}[OK]${NC}   spawn.h installed to $PREFIX/include"
fi

# Install systemctl stub
if curl -sfL "$REPO_BASE/patches/systemctl" -o "$PREFIX/bin/systemctl" 2>/dev/null; then
    chmod +x "$PREFIX/bin/systemctl"
    echo -e "${GREEN}[OK]${NC}   systemctl stub installed"
fi

# ─────────────────────────────────────────────
step 4 "Patching Hardcoded Paths"

# Run patch-paths.sh
PATCH_SCRIPT="$OPENCLAW_DIR/patch-paths.sh"
if curl -sfL "$REPO_BASE/patches/patch-paths.sh" -o "$PATCH_SCRIPT" 2>/dev/null; then
    chmod +x "$PATCH_SCRIPT"
    bash "$PATCH_SCRIPT" || true
else
    echo -e "${YELLOW}[WARN]${NC} Failed to download patch-paths.sh"
fi

# ─────────────────────────────────────────────
step 5 "Updating OpenClaw"

echo "Running: openclaw update"
openclaw update || echo -e "${YELLOW}[WARN]${NC} openclaw update failed"

# ─────────────────────────────────────────────
step 6 "Updating CLI Tools"

# Update oa command
echo "Updating oa command..."
OA_SCRIPT="$PREFIX/bin/oa"
if curl -sfL "$REPO_BASE/oa.sh" -o "$OA_SCRIPT" 2>/dev/null; then
    chmod +x "$OA_SCRIPT"
    echo -e "${GREEN}[OK]${NC}   oa updated"
else
    echo -e "${YELLOW}[WARN]${NC} Failed to update oa"
fi

# Update oaupdate command
OAUPDATE_SCRIPT="$PREFIX/bin/oaupdate"
if curl -sfL "$REPO_BASE/update.sh" -o "$OAUPDATE_SCRIPT" 2>/dev/null; then
    chmod +x "$OAUPDATE_SCRIPT"
    echo -e "${GREEN}[OK]${NC}   oaupdate updated"
fi

# ─────────────────────────────────────────────
step 7 "Installing Additional Tools (Optional)"

# Install AI CLI tools (interactive)
AI_TOOLS_SCRIPT="$OPENCLAW_DIR/install-ai-tools.sh"
if curl -sfL "$REPO_BASE/scripts/install-ai-tools.sh" -o "$AI_TOOLS_SCRIPT" 2>/dev/null; then
    chmod +x "$AI_TOOLS_SCRIPT"
    echo "AI CLI tools installer ready (run: bash $AI_TOOLS_SCRIPT)"
fi

# Install code-server (optional, takes time)
if [ -t 0 ]; then
    echo ""
    read -rp "Install code-server (browser IDE)? [y/N] " REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        CODE_SERVER_SCRIPT="$OPENCLAW_DIR/install-code-server.sh"
        if curl -sfL "$REPO_BASE/scripts/install-code-server.sh" -o "$CODE_SERVER_SCRIPT" 2>/dev/null; then
            chmod +x "$CODE_SERVER_SCRIPT"
            bash "$CODE_SERVER_SCRIPT" install || true
        fi
    fi
fi

# ─────────────────────────────────────────────
step 8 "Updating Environment"

# Re-apply environment variables
ENV_SCRIPT="$OPENCLAW_DIR/setup-env.sh"
if curl -sfL "$REPO_BASE/scripts/setup-env.sh" -o "$ENV_SCRIPT" 2>/dev/null; then
    chmod +x "$ENV_SCRIPT"
    bash "$ENV_SCRIPT" || true
    echo -e "${GREEN}[OK]${NC}   Environment updated"
fi

# ─────────────────────────────────────────────
step 9 "Verification"

echo ""
echo "Running verification..."
VERIFY_SCRIPT="$OPENCLAW_DIR/verify-install.sh"
if curl -sfL "$REPO_BASE/tests/verify-install.sh" -o "$VERIFY_SCRIPT" 2>/dev/null; then
    chmod +x "$VERIFY_SCRIPT"
    bash "$VERIFY_SCRIPT" || true
fi

# ─────────────────────────────────────────────
# Done

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}  Update Complete!${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "  OpenClaw: $(openclaw --version 2>/dev/null || echo 'installed')"
echo ""
echo "Commands:"
echo "  oa --status    Show installation status"
echo "  oa --update    Update again"
echo "  oa --help      Show all options"
echo ""
