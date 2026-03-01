# OpenClaw on Android - ![Termux](https://img.shields.io/badge/Termux-000000?style=for-the-badge&logo=android&logoColor=white) ![OpenClaw](https://img.shields.io/badge/OpenClaw-4285F4?style=for-the-badge&logo=openai&logoColor=white) ![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)

![Platform](https://img.shields.io/badge/Platform-Android_7%2B-green.svg)
![ARM64](https://img.shields.io/badge/Architecture-ARM64-blue.svg)
![Modular](https://img.shields.io/badge/Install-Modular-9cf.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

The **easiest way** to run OpenClaw on Android. Modular installer, native builds supported, no proot needed. 🚀

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **🔧 Modular Installer** | Clean, maintainable scripts for each step |
| **🛠️ Native Builds** | Compatibility patches for koffi, sharp, and other native modules |
| **⚡ One-Line Install** | Copy, paste, done |
| **📱 Native Termux** | No proot-distro needed |
| **🔋 Wake Lock** | Prevents background kills |
| **🎨 CLI Tools** | `oa`, `jarvis`, `oaupdate` commands |
| **📦 Auto-Dependencies** | cmake, clang, make, and 22+ packages |

---

## ⚡ Quick Start

**After installing Termux, run these commands:**

```bash
# Step 1: Update Termux packages
pkg update -y && pkg upgrade -y

# Step 2: Install curl (required for one-liner)
pkg install curl -y

# Step 3: Run the installer
curl -sL https://raw.githubusercontent.com/Vamsiindugu/Openclaw-on-Android/main/install.sh | bash
```

After installation:

```bash
source ~/.bashrc    # Activate environment
openclaw status     # Check system status
openclaw init       # Run initial setup
```

---

## 📋 Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **Android** | 7.0+ | 10.0+ |
| **RAM** | 2GB | 4GB+ |
| **Storage** | 500MB | 1GB+ |
| **Architecture** | ARM64 | ARM64 |
| **Termux** | Latest | From F-Droid |

> ⚠️ **Important**: Install Termux from **F-Droid**, not Play Store. Play Store version is outdated.

---

## 🔧 Installation Guide

### Step 1: Install Termux

Download from F-Droid (recommended):
```
https://f-droid.org/packages/com.termux/
```

### Step 2: Update Termux & Install curl

```bash
pkg update -y && pkg upgrade -y
pkg install curl -y
```

### Step 3: Run Installer

```bash
curl -sL https://raw.githubusercontent.com/Vamsiindugu/Openclaw-on-Android/main/install.sh | bash
```

### Step 4: Initialize

```bash
source ~/.bashrc
openclaw init
```

### Step 5: Start Gateway (Optional)

```bash
openclaw gateway start
```

---

## 📁 Project Structure

```
Openclaw-on-Android/
├── install.sh              # Main installer
├── oa.sh                   # OpenClaw CLI wrapper
├── update.sh               # Update script
├── scripts/
│   ├── check-env.sh        # Environment validation
│   ├── install-deps.sh     # Package installation
│   ├── setup-paths.sh      # Directory setup
│   ├── setup-env.sh        # Environment variables
│   └── build-sharp.sh      # Sharp image library build
└── patches/
    ├── bionic-compat.js    # Bionic libc compatibility
    ├── termux-compat.h     # Termux build compatibility
    ├── spawn.h             # posix_spawn stub for koffi
    └── apply-patches.sh    # Apply patches post-install
```

---

## 🛠️ CLI Commands

| Command | Description |
|---------|-------------|
| `oa` | OpenClaw shortcut |
| `oaupdate` | Update OpenClaw installation |
| `jarvis` | OpenClaw chat mode |
| `claw-status` | Check system status |
| `claw-start` | Start gateway |
| `claw-stop` | Stop gateway |

---

## 🌐 Browser Extension

For browser automation:

1. Install **Lemur Browser** or **Kiwi Browser** from Play Store
2. Run: `openclaw browser extension install`
3. In browser: `chrome://extensions` → Enable Developer mode → Load unpacked
4. Select the extension directory shown by the command

---

## 🤖 Telegram Bot Setup

### Step 1: Create Bot

1. Open Telegram, search **@BotFather**
2. Send `/newbot`
3. Follow prompts, save the **BOT TOKEN**

### Step 2: Configure OpenClaw

Edit `~/.openclaw/openclaw.json`:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN_HERE",
      "dmPolicy": "pairing"
    }
  }
}
```

### Step 3: Start & Pair

```bash
openclaw gateway start
openclaw pairing list telegram
openclaw pairing approve telegram <CODE>
```

---

## 🛒 Skills Marketplace

Extend OpenClaw with skills from **ClawHub**:

| Skill | Description |
|-------|-------------|
| `skillboss` | Fullstack app builder |
| `qmd-skill` | Markdown search |
| `x-research` | X/Twitter research |
| `weather` | Weather forecasts |
| `humanizer` | AI text humanizer |

Browse more: **https://clawhub.com**

---

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| **make: -j option requires positive integer** | Fixed in v1.1.2+. Manual: `export JOBS=1` |
| **cmake not found** | Install: `pkg install cmake` |
| **spawn.h missing** | Installer provides stub in `$PREFIX/include/spawn.h` |
| **npm install fails** | Run `pkg upgrade && npm cache clean --force` |
| **Memory error** | Check `echo $NODE_OPTIONS` (should show 4096) |
| **Gateway won't start** | Check port: `lsof -i :18789` and kill process |
| **Termux killed in background** | Enable wake lock: `termux-wake-lock` |
| **command not found: openclaw** | Run `hash -r` or `source ~/.bashrc` |

### Get Help

- 💬 **Discord**: https://discord.gg/clawd
- 📖 **Docs**: https://docs.openclaw.ai
- 🐛 **Issues**: https://github.com/openclaw/openclaw/issues

---

## 🤝 Contributing

Contributions welcome! 🙌

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📧 Contact

### Vamsi Indugu
- 💌 Email: [vamsiindugu@gmail.com](mailto:vamsiindugu@gmail.com)
- 🌐 Portfolio: [vamsiindugu.vercel.app](https://vamsiindugu.vercel.app/)
- 🐱 GitHub: [@Vamsiindugu](https://github.com/Vamsiindugu/)
- 💼 LinkedIn: [vamsi-indugu](https://www.linkedin.com/in/vamsi-indugu/)

---

## 🔗 Links

| Resource | URL |
|----------|-----|
| **OpenClaw Docs** | https://docs.openclaw.ai |
| **GitHub** | https://github.com/openclaw/openclaw |
| **Discord** | https://discord.gg/clawd |
| **ClawHub (Skills)** | https://clawhub.com |
| **Termux (F-Droid)** | https://f-droid.org/packages/com.termux/ |

---

## 📜 Changelog

### v1.2.0
- Modular installer architecture
- Compatibility patches (bionic-compat.js, termux-compat.h, spawn.h)
- CLI tools: `oa`, `oaupdate`
- JOBS=1 fix for native builds
- cmake added to dependencies

### v1.1.2
- Fixed make -j error with JOBS=1

### v1.1.1
- Added cmake to dependencies

### v1.1.0
- Initial release

---

© 2026 Vamsi Indugu. All rights reserved.

**Made with ❤️ for the Android community.**

---

![Star](https://img.shields.io/github/stars/Vamsiindugu/Openclaw-on-android?style=social) ![Fork](https://img.shields.io/github/forks/Vamsiindugu/Openclaw-on-android?style=social)
