#!/usr/bin/env bash
# update.sh - Update OpenClaw Android installation
# Usage: oaupdate

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}OpenClaw Android Updater${NC}"
echo "----------------------------------------"
echo ""

# Ensure JOBS is set for npm builds
export JOBS=1

echo "Updating OpenClaw..."
if npm update -g openclaw 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC} OpenClaw updated"
else
    echo -e "${YELLOW}[WARN]${NC} Update had issues"
    echo "Try: npm install -g openclaw@latest"
fi

# Update clawhub if installed
if command -v clawhub &>/dev/null; then
    echo ""
    echo "Updating clawhub..."
    if npm update -g clawdhub 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC} clawhub updated"
    fi
fi

# Show version
echo ""
echo -e "${BOLD}Installed versions:${NC}"
echo "OpenClaw: $(openclaw --version 2>/dev/null || echo 'unknown')"
echo "Node.js: $(node -v 2>/dev/null || echo 'unknown')"
echo "npm: $(npm -v 2>/dev/null || echo 'unknown')"

echo ""
echo -e "${GREEN}Update complete${NC}"
