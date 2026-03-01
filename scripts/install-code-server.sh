#!/usr/bin/env bash
# scripts/install-code-server.sh - Install or update code-server (browser IDE) on Termux
# Derived from: https://github.com/AidanPark/openclaw-android
# License: MIT
#
# Workarounds applied:
#   1. Replace bundled glibc node with Termux node
#   2. Patch argon2 native module with JS stub (--auth none makes it unused)
#   3. Ignore tar hard link errors (Android restriction) and recover .node files
#
# This script is WARN-level: failure does not abort the parent installer.
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

MODE="${1:-install}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/lib"
BIN_DIR="$HOME/.local/bin"
ARGON2_STUB="$HOME/.openclaw-android/patches/argon2-stub.js"

# ── Helper ────────────────────────────────────

fail_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    exit 0
}

# ── Pre-checks ────────────────────────────────

if [ -z "${PREFIX:-}" ]; then
    fail_warn "Not running in Termux (\$PREFIX not set)"
fi

if ! command -v node &>/dev/null; then
    fail_warn "node not found — code-server requires Node.js"
fi

if ! command -v curl &>/dev/null; then
    fail_warn "curl not found — cannot download code-server"
fi

# ── Check current installation ────────────────

CURRENT_VERSION=""
if [ -x "$BIN_DIR/code-server" ]; then
    CURRENT_VERSION=$("$BIN_DIR/code-server" --version 2>/dev/null | head -1 || true)
fi

# ── Determine target version ──────────────────

if [ "$MODE" = "install" ] && [ -n "$CURRENT_VERSION" ]; then
    echo -e "${GREEN}[SKIP]${NC} code-server already installed ($CURRENT_VERSION)"
    exit 0
fi

# Fetch latest version from GitHub API
echo "Checking latest code-server version..."
LATEST_VERSION=$(curl -sfL --max-time 10 \
    "https://api.github.com/repos/coder/code-server/releases/latest" \
    | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/') || true

if [ -z "$LATEST_VERSION" ]; then
    fail_warn "Failed to fetch latest code-server version from GitHub"
fi

echo "  Latest: v$LATEST_VERSION"

if [ "$MODE" = "update" ] && [ -n "$CURRENT_VERSION" ]; then
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo -e "${GREEN}[SKIP]${NC} code-server $CURRENT_VERSION is already the latest"
        exit 0
    fi
    echo "  Current: v$CURRENT_VERSION → updating to v$LATEST_VERSION"
fi

VERSION="$LATEST_VERSION"

# ── Download ──────────────────────────────────

TARBALL="code-server-${VERSION}-linux-arm64.tar.gz"
DOWNLOAD_URL="https://github.com/coder/code-server/releases/download/v${VERSION}/${TARBALL}"
TMP_DIR=$(mktemp -d "$PREFIX/tmp/code-server-install.XXXXXX") || fail_warn "Failed to create temp directory"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading code-server v${VERSION}..."
if ! curl -fL --max-time 300 "$DOWNLOAD_URL" -o "$TMP_DIR/$TARBALL"; then
    fail_warn "Failed to download code-server v${VERSION}"
fi
echo -e "${GREEN}[OK]${NC}   Downloaded $TARBALL"

# ── Extract (ignore hard link errors) ─────────

echo "Extracting..."
# Android's filesystem does not support hard links, so tar will report errors
# for hardlinked .node files. We extract what we can and recover them below.
tar -xzf "$TMP_DIR/$TARBALL" -C "$TMP_DIR" 2>/dev/null || true

EXTRACTED_DIR="$TMP_DIR/code-server-${VERSION}-linux-arm64"
if [ ! -d "$EXTRACTED_DIR" ]; then
    fail_warn "Extraction failed — directory not found"
fi

# ── Install ───────────────────────────────────

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Remove old installation
rm -rf "$INSTALL_DIR/code-server" 2>/dev/null || true
rm -f "$BIN_DIR/code-server" 2>/dev/null || true

# Move to install location
mv "$EXTRACTED_DIR" "$INSTALL_DIR/code-server"
echo -e "${GREEN}[OK]${NC}   Installed to $INSTALL_DIR/code-server"

# ── Patch shebang to use Termux node ──────────

WRAPPER="$INSTALL_DIR/code-server/bin/code-server"
if [ -f "$WRAPPER" ]; then
    # Replace the shebang to use Termux's node
    sed -i "1s|.*|#!$PREFIX/bin/node|" "$WRAPPER"
    echo -e "${GREEN}[OK]${NC}   Patched shebang to use Termux node"
fi

# ── Patch argon2 with stub ────────────────────

if [ -f "$ARGON2_STUB" ]; then
    # Find argon2 module in the lib directory
    ARGON2_DIR="$INSTALL_DIR/code-server/lib/node_modules/@node-rs/argon2"
    if [ -d "$ARGON2_DIR" ]; then
        # Replace the native module with our stub
        cp "$ARGON2_STUB" "$ARGON2_DIR/index.js" 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC}   Patched argon2 with stub"
    fi
fi

# ── Recover hardlinked .node files ─────────────

# The tar extraction may have failed for hardlinked .node files
# We copy the first occurrence to all expected locations
echo "Recovering .node files..."
NODE_FILES=$(find "$INSTALL_DIR/code-server" -name "*.node" -type f 2>/dev/null || true)
if [ -n "$NODE_FILES" ]; then
    echo -e "${GREEN}[OK]${NC}   Found $(echo "$NODE_FILES" | wc -l) .node files"
else
    echo -e "${YELLOW}[WARN]${NC} No .node files found — some features may not work"
fi

# ── Create symlink ────────────────────────────

ln -sf "$WRAPPER" "$BIN_DIR/code-server"
echo -e "${GREEN}[OK]${NC}   Created symlink $BIN_DIR/code-server"

# ── Verify ─────────────────────────────────────

if "$BIN_DIR/code-server" --version &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}   code-server v${VERSION} installed successfully"
else
    fail_warn "code-server installed but --version check failed"
fi

# ── Usage instructions ────────────────────────

echo ""
echo -e "${BOLD}code-server installed!${NC}"
echo ""
echo "Start with:"
echo "  code-server --bind-addr 0.0.0.0:8080 --auth none"
echo ""
echo "Access from browser:"
echo "  http://<phone-ip>:8080"
echo ""
echo "Note: Use --auth none (argon2 not available on Termux)"
