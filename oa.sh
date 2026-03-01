#!/usr/bin/env bash
# oa.sh - OpenClaw Android CLI wrapper
# Usage: oa [command] [args]

set -e

# Source environment if not already loaded
if [ -z "${CLAWDHUB_WORKDIR:-}" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    export TMPDIR="${TMPDIR:-$PREFIX/tmp}"
    export JOBS="${JOBS:-1}"
    export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=4096}"
    export CLAWDHUB_WORKDIR="$HOME/.openclaw/workspace"
fi

# Run openclaw with all arguments
openclaw "$@"
