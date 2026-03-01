#!/usr/bin/env bash
# uninstall.sh - Remove OpenClaw on Android from Termux
# Derived from: https://github.com/AidanPark/openclaw-android
# License: MIT
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  OpenClaw on Android - Uninstaller${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

# Confirm
read -rp "This will remove OpenClaw and all related config. Continue? [y/N] " REPLY
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""

# 1. Uninstall OpenClaw npm package
echo "Removing OpenClaw npm package..."
if command -v openclaw &>/dev/null; then
    npm uninstall -g openclaw 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   openclaw package removed"
else
    echo -e "${YELLOW}[SKIP]${NC} openclaw not installed"
fi

# 2. Remove clawhub
echo ""
echo "Removing clawhub..."
if npm list -g clawdhub &>/dev/null; then
    npm uninstall -g clawdhub 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   clawhub removed"
else
    echo -e "${YELLOW}[SKIP]${NC} clawhub not installed"
fi

# 3. Remove oa and oaupdate commands
if [ -f "$PREFIX/bin/oa" ]; then
    rm -f "$PREFIX/bin/oa"
    echo -e "${GREEN}[OK]${NC}   Removed $PREFIX/bin/oa"
else
    echo -e "${YELLOW}[SKIP]${NC} $PREFIX/bin/oa not found"
fi

if [ -f "$PREFIX/bin/oaupdate" ]; then
    rm -f "$PREFIX/bin/oaupdate"
    echo -e "${GREEN}[OK]${NC}   Removed $PREFIX/bin/oaupdate"
else
    echo -e "${YELLOW}[SKIP]${NC} $PREFIX/bin/oaupdate not found"
fi

# 4. Remove spawn.h stub
if [ -f "$PREFIX/include/spawn.h" ]; then
    # Check if it's our stub (not a real system file)
    if grep -q "spawn.h - Minimal stub for Termux" "$PREFIX/include/spawn.h" 2>/dev/null; then
        rm -f "$PREFIX/include/spawn.h"
        echo -e "${GREEN}[OK]${NC}   Removed spawn.h stub"
    fi
fi

# 5. Remove openclaw-android directory
if [ -d "$HOME/.openclaw-android" ]; then
    rm -rf "$HOME/.openclaw-android"
    echo -e "${GREEN}[OK]${NC}   Removed $HOME/.openclaw-android"
else
    echo -e "${YELLOW}[SKIP]${NC} $HOME/.openclaw-android not found"
fi

# 6. Remove environment block from .bashrc
BASHRC="$HOME/.bashrc"
MARKER_START="# ═══════════════════════════════════════════════════════════════"
MARKER_TEXT="OpenClaw Android - Environment Variables"

if [ -f "$BASHRC" ] && grep -qF "$MARKER_TEXT" "$BASHRC"; then
    # Remove the block between the markers
    sed -i "/$MARKER_TEXT/,/OpenClaw environment end/d" "$BASHRC" 2>/dev/null || true
    # Also remove any remaining marker lines
    sed -i "/═══════════════════════════════════════════════════════════════/d" "$BASHRC" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   Removed environment block from $BASHRC"
else
    echo -e "${YELLOW}[SKIP]${NC} No environment block found in $BASHRC"
fi

# 7. Clean up temp directory
if [ -d "$PREFIX/tmp/openclaw" ]; then
    rm -rf "$PREFIX/tmp/openclaw"
    echo -e "${GREEN}[OK]${NC}   Removed $PREFIX/tmp/openclaw"
fi

# 8. Optionally remove openclaw data
echo ""
if [ -d "$HOME/.openclaw" ]; then
    read -rp "Remove OpenClaw data directory ($HOME/.openclaw)? [y/N] " REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.openclaw"
        echo -e "${GREEN}[OK]${NC}   Removed $HOME/.openclaw"
    else
        echo -e "${YELLOW}[KEEP]${NC} Keeping $HOME/.openclaw"
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}Uninstall complete.${NC}"
echo "Restart your Termux session to clear environment variables."
echo ""
