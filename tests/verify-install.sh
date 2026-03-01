#!/usr/bin/env bash
# tests/verify-install.sh - Verify OpenClaw installation on Termux
# Derived from: https://github.com/AidanPark/openclaw-android
# License: MIT
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS=$((PASS + 1))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL=$((FAIL + 1))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARN=$((WARN + 1))
}

echo ""
echo -e "${GREEN}=== OpenClaw on Android - Installation Verification ===${NC}"
echo ""

# 1. Node.js version
if command -v node &>/dev/null; then
    NODE_VER=$(node -v)
    NODE_MAJOR="${NODE_VER%%.*}"
    NODE_MAJOR="${NODE_MAJOR#v}"
    if [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
        check_pass "Node.js $NODE_VER (>= 18)"
    else
        check_fail "Node.js $NODE_VER (need >= 18)"
    fi
else
    check_fail "Node.js not found"
fi

# 2. npm available
if command -v npm &>/dev/null; then
    check_pass "npm $(npm -v)"
else
    check_fail "npm not found"
fi

# 3. openclaw command
if command -v openclaw &>/dev/null; then
    CLAW_VER=$(openclaw --version 2>/dev/null || echo "error")
    if [ "$CLAW_VER" != "error" ]; then
        check_pass "openclaw $CLAW_VER"
    else
        check_warn "openclaw found but --version failed"
    fi
else
    check_fail "openclaw command not found"
fi

# 4. Environment variables
if [ -n "${TMPDIR:-}" ]; then
    check_pass "TMPDIR=$TMPDIR"
else
    check_warn "TMPDIR not set"
fi

if [ -n "${NODE_OPTIONS:-}" ]; then
    check_pass "NODE_OPTIONS is set"
else
    check_warn "NODE_OPTIONS not set"
fi

if [ "${JOBS:-}" = "1" ]; then
    check_pass "JOBS=1 (parallel build fix)"
else
    check_warn "JOBS not set (native builds may fail)"
fi

# 5. Patch files
COMPAT_FILE="$HOME/.openclaw-android/patches/bionic-compat.js"
if [ -f "$COMPAT_FILE" ]; then
    check_pass "bionic-compat.js exists"
else
    check_warn "bionic-compat.js not found"
fi

COMPAT_HEADER="$HOME/.openclaw-android/patches/termux-compat.h"
if [ -f "$COMPAT_HEADER" ]; then
    check_pass "termux-compat.h exists"
else
    check_warn "termux-compat.h not found"
fi

SPAWN_H="$PREFIX/include/spawn.h"
if [ -f "$SPAWN_H" ]; then
    check_pass "spawn.h stub installed"
else
    check_warn "spawn.h not found (koffi builds may fail)"
fi

# 6. Directories
for DIR in "$HOME/.openclaw-android" "$HOME/.openclaw" "$PREFIX/tmp"; do
    if [ -d "$DIR" ]; then
        check_pass "Directory $DIR exists"
    else
        check_fail "Directory $DIR missing"
    fi
done

# 7. .bashrc contains env block
if grep -qF "OpenClaw Android - Environment" "$HOME/.bashrc" 2>/dev/null; then
    check_pass ".bashrc contains environment block"
else
    check_warn ".bashrc missing environment block"
fi

# 8. clawhub
if command -v clawhub &>/dev/null; then
    check_pass "clawhub installed"
else
    check_warn "clawhub not installed"
fi

# 9. Build tools
if command -v cmake &>/dev/null; then
    check_pass "cmake available"
else
    check_fail "cmake not found (native builds will fail)"
fi

if command -v clang &>/dev/null; then
    check_pass "clang available"
else
    check_fail "clang not found (native builds will fail)"
fi

# 10. Disk space
AVAIL_MB=$(df "${PREFIX:-/}" 2>/dev/null | awk 'NR==2 {print int($4/1024)}') || true
if [ -n "$AVAIL_MB" ] && [ "$AVAIL_MB" -ge 100 ]; then
    check_pass "Available storage: ${AVAIL_MB}MB"
elif [ -n "$AVAIL_MB" ]; then
    check_warn "Low storage: ${AVAIL_MB}MB"
else
    check_warn "Could not determine available storage"
fi

# Summary
echo ""
echo "==============================="
echo -e "  Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}, ${YELLOW}$WARN warnings${NC}"
echo "==============================="
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}Installation verification FAILED.${NC}"
    echo "Please check the errors above and re-run install.sh"
    exit 1
else
    echo -e "${GREEN}Installation verification PASSED!${NC}"
fi
