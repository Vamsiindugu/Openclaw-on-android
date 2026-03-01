#!/usr/bin/env bash
# patches/patch-paths.sh - Patch hardcoded Linux paths in OpenClaw modules
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Patching Hardcoded Paths ==="
echo ""

# Ensure TMPDIR is set
export TMPDIR="${TMPDIR:-$PREFIX/tmp}"

# Find OpenClaw installation directory
NPM_ROOT=$(npm root -g 2>/dev/null)
OPENCLAW_DIR="$NPM_ROOT/openclaw"

if [ ! -d "$OPENCLAW_DIR" ]; then
    echo -e "${RED}[FAIL]${NC} OpenClaw not found at $OPENCLAW_DIR"
    exit 1
fi

echo "OpenClaw found at: $OPENCLAW_DIR"

PATCHED=0

# Patch /tmp references to $PREFIX/tmp
echo "Patching /tmp references..."
TMP_FILES=$(grep -rl '/tmp' "$OPENCLAW_DIR" --include='*.js' --include='*.mjs' --include='*.cjs' 2>/dev/null || true)

for f in $TMP_FILES; do
    if [ -f "$f" ]; then
        sed -i "s|\"\/tmp/|\"$PREFIX/tmp/|g" "$f"
        sed -i "s|'\/tmp/|'$PREFIX/tmp/|g" "$f"
        sed -i "s|\`\/tmp/|\`$PREFIX/tmp/|g" "$f"
        sed -i "s|\"\/tmp\"|\"$PREFIX/tmp\"|g" "$f"
        sed -i "s|'\/tmp'|'$PREFIX/tmp'|g" "$f"
        echo -e "  ${GREEN}[PATCHED]${NC} $(basename $f) (tmp path)"
        PATCHED=$((PATCHED + 1))
    fi
done

# Patch /bin/sh references
echo "Patching /bin/sh references..."
SH_FILES=$(grep -rl '"/bin/sh"' "$OPENCLAW_DIR" --include='*.js' --include='*.mjs' --include='*.cjs' 2>/dev/null || true)

for f in $SH_FILES; do
    if [ -f "$f" ]; then
        sed -i "s|\"\/bin\/sh\"|\"$PREFIX/bin/sh\"|g" "$f"
        sed -i "s|'\/bin\/sh'|'$PREFIX/bin/sh'|g" "$f"
        echo -e "  ${GREEN}[PATCHED]${NC} $(basename $f) (bin/sh)"
        PATCHED=$((PATCHED + 1))
    fi
done

# Patch /bin/bash references
echo "Patching /bin/bash references..."
BASH_FILES=$(grep -rl '"/bin/bash"' "$OPENCLAW_DIR" --include='*.js' --include='*.mjs' --include='*.cjs' 2>/dev/null || true)

for f in $BASH_FILES; do
    if [ -f "$f" ]; then
        sed -i "s|\"\/bin\/bash\"|\"$PREFIX/bin/bash\"|g" "$f"
        sed -i "s|'\/bin\/bash'|'$PREFIX/bin/bash'|g" "$f"
        echo -e "  ${GREEN}[PATCHED]${NC} $(basename $f) (bin/bash)"
        PATCHED=$((PATCHED + 1))
    fi
done

# Patch /usr/bin/env references
echo "Patching /usr/bin/env references..."
ENV_FILES=$(grep -rl '"/usr/bin/env"' "$OPENCLAW_DIR" --include='*.js' --include='*.mjs' --include='*.cjs' 2>/dev/null || true)

for f in $ENV_FILES; do
    if [ -f "$f" ]; then
        sed -i "s|\"\/usr\/bin\/env\"|\"$PREFIX/bin/env\"|g" "$f"
        sed -i "s|'\/usr\/bin\/env'|'$PREFIX/bin/env'|g" "$f"
        echo -e "  ${GREEN}[PATCHED]${NC} $(basename $f) (usr/bin/env)"
        PATCHED=$((PATCHED + 1))
    fi
done

echo ""
if [ "$PATCHED" -eq 0 ]; then
    echo -e "${YELLOW}[INFO]${NC} No hardcoded paths found to patch."
else
    echo -e "${GREEN}Patched $PATCHED file(s).${NC}"
fi
