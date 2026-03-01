#!/usr/bin/env bash
# scripts/install-deps.sh - Install required dependencies for OpenClaw on Android

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Updating package lists..."

# Update packages
if ! pkg update -y 2>/dev/null; then
    echo -e "${YELLOW}[WARN]${NC} pkg update had issues, trying upgrade..."
    pkg upgrade -y || true
fi

# Required packages for OpenClaw and native builds
PACKAGES=(
    # Core
    "nodejs"
    "git"
    "curl"
    "wget"
    
    # Python (for node-gyp)
    "python"
    
    # Build tools (required for native modules like koffi)
    "clang"
    "cmake"
    "make"
    "pkg-config"
    "binutils"
    
    # Libraries
    "libjpeg-turbo"
    "libpng"
    "zlib"
    "openssl"
    
    # Utilities
    "openssh"
    "tmux"
    "nano"
    "vim"
    "jq"
    "fzf"
    "ripgrep"
    "fd"
)

echo "Installing ${#PACKAGES[@]} packages..."

# Try bulk install first
if pkg install -y "${PACKAGES[@]}" 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC} All packages installed"
else
    echo -e "${YELLOW}[WARN]${NC} Bulk install had issues, installing individually..."
    FAILED=()
    for PKG in "${PACKAGES[@]}"; do
        if ! pkg install -y "$PKG" 2>/dev/null; then
            FAILED+=("$PKG")
        fi
    done
    
    if [ ${#FAILED[@]} -gt 0 ]; then
        echo -e "${YELLOW}[WARN]${NC} Failed packages: ${FAILED[*]}"
        echo "These may be optional. Continuing..."
    fi
fi

# Verify Node.js
if ! command -v node &>/dev/null; then
    echo "[ERROR] Node.js installation failed!"
    exit 1
fi

NODE_VER=$(node -v)
NPM_VER=$(npm -v)
echo -e "${GREEN}[OK]${NC} Node.js: $NODE_VER"
echo -e "${GREEN}[OK]${NC} npm: $NPM_VER"

# Configure npm for Termux
npm config set python python3 2>/dev/null || true
npm config set scripts-prepend-node-path true 2>/dev/null || true

echo -e "${GREEN}[OK]${NC} Dependencies installed"
