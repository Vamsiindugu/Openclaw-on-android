#!/usr/bin/env bash
# scripts/build-sharp.sh - Build sharp for image processing (optional)

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Building sharp (image processing library)..."
echo "This is optional and may take a few minutes."

# sharp requires prebuilt binaries or compilation
# Try to install with prebuilt first, fallback to build

if npm install -g sharp 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC} sharp installed"
else
    echo -e "${YELLOW}[INFO]${NC} sharp build failed (non-critical)"
    echo "Image processing features may be limited"
fi
