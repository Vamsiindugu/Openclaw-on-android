#!/usr/bin/env bash
# patches/apply-patches.sh - Apply post-install patches to OpenClaw modules

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Applying compatibility patches..."

OCL_DIR="$PREFIX/lib/node_modules/openclaw"

# Check if OpenClaw is installed
if [ ! -d "$OCL_DIR" ]; then
    echo -e "${YELLOW}[INFO]${NC} OpenClaw not found in $OCL_DIR"
    echo "Skipping patches"
    exit 0
fi

# Install spawn.h stub if missing (needed for koffi builds)
if [ ! -f "$PREFIX/include/spawn.h" ]; then
    cp "$HOME/.openclaw-android/patches/spawn.h" "$PREFIX/include/spawn.h" 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} spawn.h stub installed"
else
    echo -e "${GREEN}[OK]${NC} spawn.h already exists"
fi

# Note: Additional patches can be added here as needed
# For example, patching specific module files for Android compatibility

echo -e "${GREEN}[OK]${NC} Patches applied"
