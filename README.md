# OpenClaw on Android

[![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)](https://github.com/Vamsiindugu/Openclaw-on-Android)
[![Termux Required](https://img.shields.io/badge/Termux-Required-orange)](https://termux.dev)
[![No proot-distro](https://img.shields.io/badge/proot--distro-Not%20Required-blue)](https://github.com/Vamsiindugu/Openclaw-on-Android)
[![License](https://img.shields.io/github/license/Vamsiindugu/Openclaw-on-Android)](LICENSE)

**Run OpenClaw on Android with a single command — no proot, no Linux distro.**

Because Android deserves a shell.

---

## Why OpenClaw on Android?

An Android phone is a great environment for running an OpenClaw server:

| Benefit | Description |
|---------|-------------|
| **Sufficient performance** | Even older phones have enough specs to run OpenClaw |
| **Repurpose old phones** | Put that drawer phone to work. No need for a mini PC |
| **Low power + built-in UPS** | Runs 24/7 on minimal power; battery keeps it alive through outages |
| **No personal data at risk** | Use a factory-reset phone with no accounts logged in |

---

## Comparison: This Project vs proot-distro

| Metric | proot-distro | This Project |
|--------|--------------|--------------|
| **Storage overhead** | 1-2GB (Linux + packages) | ~50MB |
| **Setup time** | 20-30 min | 3-10 min |
| **Performance** | Slower (proot layer) | Native speed |
| **Setup steps** | Install distro, configure Linux, install Node.js, fix paths... | Run one command |

---

## Features

### Core Features
- ✅ **One-command install** — Just curl and bash
- ✅ **No proot-distro** — Runs natively in Termux
- ✅ **Compatibility patches** — Handles Termux/Android quirks
- ✅ **Automatic updates** — `oa --update` handles everything

### Compatibility Patches
| Patch | Purpose |
|-------|---------|
| `bionic-compat.js` | Bionic libc compatibility for Node.js |
| `termux-compat.h` | Build compatibility headers |
| `spawn.h` | posix_spawn stub for koffi module |
| `argon2-stub.js` | JS stub for code-server (no native argon2) |
| `systemctl` | Stub for systemd commands |
| `patch-paths.sh` | Patches hardcoded Linux paths |

### CLI Tools
| Tool | Description |
|------|-------------|
| `oa` | OpenClaw manager (status, update, uninstall) |
| `oaupdate` | Quick update command |
| `jarvis` | OpenClaw chat mode |

### Optional Components
- **code-server** — Browser-based VS Code IDE
- **Claude Code CLI** — Anthropic's AI coding assistant
- **Gemini CLI** — Google's AI assistant
- **Codex CLI** — OpenAI's coding assistant
- **ttyd** — Web terminal
- **dufs** — File server

---

## Requirements

- **Android 7.0+** (Android 10+ recommended)
- **~500MB free storage**
- **Wi-Fi or mobile data**

---

## Installation

### Step 1: Update Termux

```bash
pkg update -y && pkg upgrade -y
```

### Step 2: Install curl

```bash
pkg install curl -y
```

### Step 3: Run Installer

```bash
curl -sL https://raw.githubusercontent.com/Vamsiindugu/Openclaw-on-Android/main/install.sh | bash
```

That's it! The installer handles everything:
- Environment validation
- Dependencies installation (22+ packages)
- Path setup
- Environment configuration
- Compatibility patches
- OpenClaw installation
- Clawhub (skill manager)
- Optional components (code-server, AI tools)

### Step 4: Activate Environment

```bash
source ~/.bashrc
```

### Step 5: Start OpenClaw

```bash
openclaw gateway start
```

---

## CLI Commands

### Main Commands

| Command | Description |
|---------|-------------|
| `oa` | OpenClaw manager |
| `oa --status` | Show detailed installation status |
| `oa --update` | Update OpenClaw and patches |
| `oa --uninstall` | Remove OpenClaw on Android |
| `oa --version` | Show version |
| `oa --help` | Show help |

### OpenClaw Commands

| Command | Description |
|---------|-------------|
| `openclaw status` | System status |
| `openclaw onboard` | Initial setup wizard |
| `openclaw gateway start` | Start gateway |
| `openclaw gateway stop` | Stop gateway |
| `openclaw update` | Update OpenClaw |

---

## File Structure

```
Openclaw-on-Android/
├── install.sh              # Main installer
├── oa.sh                   # CLI manager
├── update.sh               # Thin update wrapper
├── update-core.sh          # Core updater logic
├── uninstall.sh            # Uninstaller
├── scripts/
│   ├── check-env.sh        # Environment validation
│   ├── install-deps.sh     # Package installation
│   ├── setup-paths.sh      # Directory setup
│   ├── setup-env.sh        # Environment variables
│   ├── build-sharp.sh      # Sharp image library build
│   ├── install-ai-tools.sh # AI CLI tools installer
│   └── install-code-server.sh # code-server installer
├── patches/
│   ├── bionic-compat.js    # Bionic libc compatibility
│   ├── termux-compat.h     # Build compatibility headers
│   ├── spawn.h             # posix_spawn stub
│   ├── argon2-stub.js      # Argon2 JS stub
│   ├── systemctl           # Systemd stub
│   ├── apply-patches.sh    # Apply patches post-install
│   └── patch-paths.sh      # Patch hardcoded paths
└── tests/
    └── verify-install.sh   # Installation verification
```

---

## Android 12+ Phantom Process Killer

**Important:** Android 12+ may kill background processes like `openclaw gateway` without warning. You'll see `[Process completed (signal 9)]`.

### Disable Phantom Process Killer

1. Enable **Wireless debugging** in Developer options
2. Pair your device:
   ```bash
   adb pair localhost:<PAIRING_PORT> <PAIRING_CODE>
   ```
3. Connect:
   ```bash
   adb connect localhost:<WIRELESS_DEBUGGING_PORT>
   ```
4. Disable the killer:
   ```bash
   adb shell "settings put global settings_enable_monitor_phantom_procs false"
   ```

This setting persists across reboots.

---

## Battery Protection

**Important:** Running a phone 24/7 at 100% charge can cause battery swelling. Limit the max charge:

| Device | Setting Location |
|--------|-----------------|
| Samsung | Settings > Battery > Battery Protection → Maximum 80% |
| Google Pixel | Settings > Battery > Battery Protection → ON |
| Other | Search for "battery protection" or "charge limit" |

---

## Troubleshooting

### openclaw command not found

```bash
source ~/.bashrc
```

### npm install fails

```bash
pkg install nodejs-lts -y
npm cache clean --force
```

### Build errors

The installer sets these automatically, but if you see native build errors:

```bash
export JOBS=1
export npm_config_jobs=1
export CFLAGS="-Wno-error=implicit-function-declaration"
export CXXFLAGS="-Wno-error=implicit-function-declaration"
```

### Gateway stops randomly

You're likely affected by the Phantom Process Killer (see above).

---

## Useful Links

| Resource | URL |
|----------|-----|
| OpenClaw Docs | https://docs.openclaw.ai |
| Clawhub (Skills) | https://clawhub.com |
| Discord Community | https://discord.gg/clawd |
| GitHub | https://github.com/openclaw/openclaw |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## License

MIT License — See [LICENSE](LICENSE)

---

## Credits

- Derived from [AidanPark/openclaw-android](https://github.com/AidanPark/openclaw-android) with improvements
- Inspired by [openclaw/openclaw](https://github.com/openclaw/openclaw)

---

*Maintained by [Vamsi Indugu](https://github.com/Vamsiindugu)*
