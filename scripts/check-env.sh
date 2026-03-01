#!/usr/bin/env bash
# scripts/check-env.sh - Environment validation for OpenClaw on Android

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Checking Termux environment..."

# Check if running in Termux
if [ -z "${TERMUX_VERSION:-}" ]; then
    echo -e "${RED}[ERROR]${NC} This script must be run in Termux!"
    echo "Install Termux from F-Droid: https://f-droid.org/packages/com.termux/"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} Termux v${TERMUX_VERSION}"

# Check architecture
ARCH=$(uname -m)
case "$ARCH" in
    aarch64|arm64)
        echo -e "${GREEN}[OK]${NC} Architecture: $ARCH (ARM64 supported)"
        ;;
    arm|armv7l)
        echo -e "${YELLOW}[WARN]${NC} Architecture: $ARCH (32-bit ARM, may have limitations)"
        ;;
    *)
        echo -e "${YELLOW}[WARN]${NC} Architecture: $ARCH (not officially tested)"
        ;;
esac

# Check Android version
ANDROID_VER=$(getprop ro.build.version.release 2>/dev/null || echo "unknown")
echo -e "${GREEN}[OK]${NC} Android version: $ANDROID_VER"

# Check available storage
STORAGE_AVAIL_KB=$(df -k "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
if [ -n "$STORAGE_AVAIL_KB" ] && [ "$STORAGE_AVAIL_KB" -lt 512000 ]; then
    echo -e "${YELLOW}[WARN]${NC} Low storage: $(df -h "$HOME" | awk 'NR==2 {print $4}') - recommend 500MB+"
else
    echo -e "${GREEN}[OK]${NC} Storage: $(df -h "$HOME" | awk 'NR==2 {print $4}') available"
fi

# Check if already installed
if command -v openclaw &>/dev/null; then
    OCL_VER=$(openclaw --version 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}[INFO]${NC} OpenClaw already installed: v$OCL_VER"
fi

echo -e "${GREEN}[OK]${NC} Environment check passed"
