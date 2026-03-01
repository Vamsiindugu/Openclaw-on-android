#!/usr/bin/env bash
# scripts/setup-paths.sh - Setup directory structure and paths

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo "Setting up directories..."

# Create OpenClaw directories
mkdir -p "$HOME/.openclaw/workspace"
mkdir -p "$HOME/.openclaw-android/patches"
mkdir -p "$HOME/.local/bin"
mkdir -p "$PREFIX/tmp"

echo -e "${GREEN}[OK]${NC} Created ~/.openclaw/workspace"
echo -e "${GREEN}[OK]${NC} Created ~/.openclaw-android/patches"
echo -e "${GREEN}[OK]${NC} Created ~/.local/bin"
echo -e "${GREEN}[OK]${NC} Created \$PREFIX/tmp"

# Ensure TMPDIR exists
export TMPDIR="$PREFIX/tmp"
mkdir -p "$TMPDIR"

echo -e "${GREEN}[OK]${NC} Paths configured"
