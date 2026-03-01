# COMPARISON: Openclaw-on-Android vs AidanPark/openclaw-android

**Analyzed:** 2026-03-01

---

## Feature Comparison

| Feature | Our Repo (v1.2.0) | AidanPark Repo | Recommendation |
|---------|-------------------|----------------|----------------|
| Modular scripts | ✅ | ✅ | Equal |
| spawn.h stub | ✅ | ✅ | Equal |
| bionic-compat.js | ✅ | ✅ | Equal |
| termux-compat.h | ✅ | ✅ | Equal |
| **patch-paths.sh** | ❌ Missing | ✅ Has it | **ADD** |
| **argon2-stub.js** | ❌ Missing | ✅ Has it | **ADD** (for code-server) |
| **systemctl stub** | ❌ Missing | ✅ Has it | **ADD** |
| **install-ai-tools.sh** | ❌ Missing | ✅ Has it | **ADD** |
| **install-code-server.sh** | ❌ Missing | ✅ Has it | **ADD** |
| **verify-install.sh** | ❌ Missing | ✅ Has it | **ADD** |
| **uninstall.sh** | ❌ Missing | ✅ Has it | **ADD** |
| oa --status | ❌ Missing | ✅ Has it | **ADD** |
| oa --uninstall | ❌ Missing | ✅ Has it | **ADD** |
| Phantom Process Killer check | ❌ Missing | ✅ Has it | **ADD** |
| ttyd/dufs installation | ❌ Missing | ✅ Has it | Optional |
| android-tools (adb) | ❌ Missing | ✅ Has it | **ADD** |

---

## Key Features to Add

### 1. patch-paths.sh (HIGH PRIORITY)
Patches hardcoded Linux paths in OpenClaw modules:
- `/tmp` → `$PREFIX/tmp`
- `/bin/sh` → `$PREFIX/bin/sh`
- `/bin/bash` → `$PREFIX/bin/bash`
- `/usr/bin/env` → `$PREFIX/bin/env`

**Why needed:** OpenClaw uses Linux paths that don't exist on Termux. This patches them automatically.

### 2. verify-install.sh (HIGH PRIORITY)
Runs tests after installation to verify everything works:
- Node.js version check
- npm available
- openclaw command
- Environment variables
- Patch files exist
- Directories created

**Why needed:** Users can confirm installation is correct.

### 3. uninstall.sh (HIGH PRIORITY)
Proper uninstaller that:
- Removes npm packages
- Removes code-server
- Removes oa/oaupdate commands
- Removes patches directory
- Cleans .bashrc
- Optionally keeps ~/.openclaw data

**Why needed:** Clean removal without leaving junk.

### 4. oa.sh Improvements (HIGH PRIORITY)
Add these options:
- `oa --status` - Show installation status
- `oa --uninstall` - Run uninstaller
- `oa --version` - Show version
- Version check against GitHub

### 5. install-ai-tools.sh (MEDIUM PRIORITY)
Interactive installer for:
- Claude Code CLI
- Gemini CLI
- Codex CLI

**Why needed:** AI development tools are useful.

### 6. install-code-server.sh (MEDIUM PRIORITY)
Browser-based VS Code:
- Downloads ARM64 build
- Patches glibc node with Termux node
- Stubs argon2 native module
- Handles hard link errors

**Why needed:** Web-based IDE for development.

### 7. Phantom Process Killer Check (HIGH PRIORITY)
Android 12+ kills background processes. This:
- Detects Android version
- Checks if PPK is disabled
- Shows instructions if not

**Why needed:** Prevents gateway from being killed.

---

## Implementation Plan

### Phase 1: Core Fixes (v1.2.1)
- [ ] Add patch-paths.sh
- [ ] Add verify-install.sh
- [ ] Add uninstall.sh
- [ ] Improve oa.sh with --status, --uninstall
- [ ] Add Phantom Process Killer check

### Phase 2: Extended Features (v1.3.0)
- [ ] Add argon2-stub.js
- [ ] Add systemctl stub
- [ ] Add install-ai-tools.sh
- [ ] Add install-code-server.sh
- [ ] Add android-tools check

---

## Code Attribution

If we use code from AidanPark/openclaw-android:
- License: MIT (same as ours)
- Attribution: "Parts derived from AidanPark/openclaw-android"
- Link: https://github.com/AidanPark/openclaw-android

---

*Analysis by JARVIS*
