#!/usr/bin/env bash
#
# ██████╗ ███╗   ██╗ ██████╗ ██████╗ ███████╗██╗     ███████╗
# ██╔═══██╗████╗  ██║██╔════╝██╔═══██╗██╔════╗██║     ██╔════╗
# ██║   ██║██╔██╗ ██║██║     ██║   ██║█████╗  ██║     █████╗  
# ██║   ██║██║╚██╗██║██║     ██║   ██║██╔══╝  ██║     ██╔══╝  
# ╚██████╔╝██║ ╚████║╚██████╗╚██████╔╝███████╗███████╗███████╗
#  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝
#                                                             
#            OpenClaw Android/Termux Installer v1.2.0
#            Easiest way to run OpenClaw on Android
#
# ============================================================
# USAGE: curl -sL https://raw.githubusercontent.com/Vamsiindugu/Openclaw-on-Android/main/install.sh | bash
# ============================================================

set -euo pipefail

# ========================
# VERSION
# ========================
VERSION="1.2.0"

# ========================
# COLOR CODES
# ========================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ========================
# HELPER FUNCTIONS
# ========================
step() {
    echo ""
    echo -e "${BOLD}[$1/9] $2${NC}"
    echo "----------------------------------------"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ========================
# BANNER
# ========================
echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD} OpenClaw on Android - Installer v${VERSION}${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo "This script installs OpenClaw on Termux without proot-distro."
echo ""

# ========================
# STEP 1: Environment Check
# ========================
step 1 "Environment Check"

# Enable wake lock to prevent background kills
if command -v termux-wake-lock &>/dev/null; then
    termux-wake-lock 2>/dev/null || true
    log_ok "Termux wake lock enabled"
fi

bash "$SCRIPT_DIR/scripts/check-env.sh"

# ========================
# STEP 2: Install Dependencies
# ========================
step 2 "Installing Dependencies"

bash "$SCRIPT_DIR/scripts/install-deps.sh"

# ========================
# STEP 3: Setup Paths
# ========================
step 3 "Setting Up Paths"

bash "$SCRIPT_DIR/scripts/setup-paths.sh"

# ========================
# STEP 4: Configure Environment
# ========================
step 4 "Configuring Environment Variables"

bash "$SCRIPT_DIR/scripts/setup-env.sh"

# Source environment for current session
export PATH="$HOME/.local/bin:$PATH"
export TMPDIR="$PREFIX/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
export NODE_OPTIONS="--max-old-space-size=4096"
export JOBS=1
export npm_config_jobs=1
export CFLAGS="-Wno-error=implicit-function-declaration"
export CXXFLAGS="-Wno-error=implicit-function-declaration"
export CLAWDHUB_WORKDIR="$HOME/.openclaw/workspace"

# ========================
# STEP 5: Install Compatibility Patches
# ========================
step 5 "Installing Compatibility Patches"

echo "Copying compatibility patches..."

# Create patches directory
mkdir -p "$HOME/.openclaw-android/patches"

# Copy bionic-compat.js
if [ -f "$SCRIPT_DIR/patches/bionic-compat.js" ]; then
    cp "$SCRIPT_DIR/patches/bionic-compat.js" "$HOME/.openclaw-android/patches/"
    log_ok "bionic-compat.js installed"
else
    log_warn "bionic-compat.js not found, skipping"
fi

# Copy termux-compat.h
if [ -f "$SCRIPT_DIR/patches/termux-compat.h" ]; then
    cp "$SCRIPT_DIR/patches/termux-compat.h" "$HOME/.openclaw-android/patches/"
    log_ok "termux-compat.h installed"
else
    log_warn "termux-compat.h not found, skipping"
fi

# Install spawn.h stub if missing (needed for koffi builds)
if [ ! -f "$PREFIX/include/spawn.h" ]; then
    if [ -f "$SCRIPT_DIR/patches/spawn.h" ]; then
        cp "$SCRIPT_DIR/patches/spawn.h" "$PREFIX/include/spawn.h"
        log_ok "spawn.h stub installed"
    fi
else
    log_ok "spawn.h already exists"
fi

# ========================
# STEP 6: Install CLI Commands
# ========================
step 6 "Installing CLI Commands"

# Install oa command
if [ -f "$SCRIPT_DIR/oa.sh" ]; then
    cp "$SCRIPT_DIR/oa.sh" "$PREFIX/bin/oa"
    chmod +x "$PREFIX/bin/oa"
    log_ok "oa command installed"
fi

# Install oaupdate command
if [ -f "$SCRIPT_DIR/update.sh" ]; then
    cp "$SCRIPT_DIR/update.sh" "$PREFIX/bin/oaupdate"
    chmod +x "$PREFIX/bin/oaupdate"
    log_ok "oaupdate command installed"
fi

# ========================
# STEP 7: Install OpenClaw
# ========================
step 7 "Installing OpenClaw"

echo ""
echo "Running: npm install -g openclaw@latest"
echo "This may take several minutes..."
echo ""

npm install -g openclaw@latest

log_ok "OpenClaw installed"

# Apply post-install patches
echo ""
if [ -f "$SCRIPT_DIR/patches/apply-patches.sh" ]; then
    bash "$SCRIPT_DIR/patches/apply-patches.sh"
fi

# ========================
# STEP 8: Build Sharp (Optional)
# ========================
step 8 "Building Sharp (Optional)"

if [ -f "$SCRIPT_DIR/scripts/build-sharp.sh" ]; then
    bash "$SCRIPT_DIR/scripts/build-sharp.sh"
fi

# ========================
# STEP 9: Install Clawhub
# ========================
step 9 "Installing Clawhub (Skill Manager)"

echo ""
echo "Installing clawhub..."

if npm install -g clawdhub --no-fund --no-audit 2>/dev/null; then
    log_ok "clawhub installed"
else
    log_warn "clawhub installation failed (non-critical)"
    echo "Install manually: npm install -g clawdhub"
fi

# ========================
# SUMMARY
# ========================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Installation Complete!                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Quick Start:${NC}"
echo ""
echo "  source ~/.bashrc        # Activate environment"
echo "  openclaw status         # Check system status"
echo "  openclaw init           # Run initial setup"
echo "  openclaw gateway start  # Start gateway"
echo ""
echo -e "${BOLD}CLI Commands:${NC}"
echo ""
echo "  oa          - OpenClaw shortcut"
echo "  jarvis      - OpenClaw chat mode"
echo "  oaupdate    - Update OpenClaw"
echo ""
echo -e "${BOLD}Useful Links:${NC}"
echo ""
echo "  📖 Docs:    https://docs.openclaw.ai"
echo "  🛒 Skills:  https://clawhub.com"
echo "  💬 Discord: https://discord.gg/clawd"
echo ""
echo -e "${YELLOW}⚠️  Restart Termux or run 'source ~/.bashrc' to apply changes!${NC}"
echo ""

# Show installed versions
echo -e "${BOLD}Installed Versions:${NC}"
echo "OpenClaw: $(openclaw --version 2>/dev/null || echo 'unknown')"
echo "Node.js: $(node -v)"
echo "npm: $(npm -v)"
echo ""
