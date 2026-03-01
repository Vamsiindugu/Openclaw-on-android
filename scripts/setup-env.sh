#!/usr/bin/env bash
# scripts/setup-env.sh - Configure environment variables for Termux/Android

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo "Configuring environment variables..."

ENV_BLOCK='
# ═══════════════════════════════════════════════════════════════
# OpenClaw Android - Environment Variables
# ═══════════════════════════════════════════════════════════════

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Temp directories
export TMPDIR="$PREFIX/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"

# Node.js memory optimization for Android
export NODE_OPTIONS="--max-old-space-size=4096"

# Build flags for native modules
export JOBS=1
export CFLAGS="-Wno-error=implicit-function-declaration"
export CXXFLAGS="-Wno-error=implicit-function-declaration"

# npm configuration
export npm_config_jobs=1

# OpenClaw specific
export CLAWDHUB_WORKDIR="$HOME/.openclaw/workspace"

# ═══════════════════════════════════════════════════════════════
# OpenClaw Aliases
# ═══════════════════════════════════════════════════════════════
alias oa="openclaw"
alias ocl="openclaw"
alias jarvis="openclaw chat"
alias claw-status="openclaw status"
alias claw-start="openclaw gateway start"
alias claw-stop="openclaw gateway stop"
alias oaupdate="oa update"

# OpenClaw environment end
# ═══════════════════════════════════════════════════════════════'

# Configure bashrc
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "OpenClaw Android - Environment Variables" "$HOME/.bashrc" 2>/dev/null; then
        echo "$ENV_BLOCK" >> "$HOME/.bashrc"
        echo -e "${GREEN}[OK]${NC} Added environment to .bashrc"
    else
        echo -e "${GREEN}[OK]${NC} Environment already in .bashrc"
    fi
else
    echo "$ENV_BLOCK" > "$HOME/.bashrc"
    echo -e "${GREEN}[OK]${NC} Created .bashrc with environment"
fi

# Configure zshrc if exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "OpenClaw Android - Environment Variables" "$HOME/.zshrc" 2>/dev/null; then
        echo "$ENV_BLOCK" >> "$HOME/.zshrc"
        echo -e "${GREEN}[OK]${NC} Added environment to .zshrc"
    fi
fi

echo -e "${GREEN}[OK]${NC} Environment variables configured"
