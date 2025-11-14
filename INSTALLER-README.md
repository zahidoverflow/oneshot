# 🎯 OneShot One-Liner Installer - Complete

## ✅ What Was Created

1. **`install.sh`** - Full automated installer script
2. **`QUICKSTART.md`** - User guide for the one-liner
3. **Updated `README.md`** - Added one-liner at the top

## 🚀 The Magic One-Liner

Users can now install OneShot with a single command:

```bash
curl -sSfL https://raw.githubusercontent.com/zahidoverflow/oneshot/master/install.sh | bash
```

## 📦 What The Installer Does

### Automatic Setup:
- ✅ Checks for Termux environment
- ✅ Verifies root access
- ✅ Updates package repositories
- ✅ Installs root-repo
- ✅ Installs all dependencies:
  - tsu (root shell)
  - Python 3
  - git, wget, curl
  - wpa-supplicant
  - pixiewps
  - iw (wireless tools)
  - openssl
- ✅ Clones OneShot from your GitHub repo
- ✅ Downloads vulnerability database
- ✅ Creates global `oneshot` command
- ✅ Detects WiFi interface
- ✅ Shows usage instructions

### Smart Features:
- Color-coded output (green/yellow/red/blue)
- Professional banner
- Error handling
- Fallback to upstream repo if needed
- Creates convenient wrapper script
- Automatic WiFi interface detection

## 📝 To Publish This

### Step 1: Commit and Push
```bash
git add install.sh QUICKSTART.md README.md
git commit -m "Add one-liner installer for Termux"
git push origin master
```

### Step 2: Users Can Now Run
```bash
curl -sSfL https://raw.githubusercontent.com/zahidoverflow/oneshot/master/install.sh | bash
```

### Step 3: After Installation
```bash
oneshot -i wlan0 --iface-down -K
```

## 🎨 What Users See

```
╔═══════════════════════════════════════╗
║     OneShot Termux Installer v1.0    ║
║   WiFi WPS Penetration Testing Tool  ║
╚═══════════════════════════════════════╝

[•] Checking root access...
[✓] Root access confirmed
[•] Updating package lists...
[•] Installing dependencies...
  → Installing tsu...
  → Installing python...
  → Installing wpa-supplicant...
  → Installing pixiewps...
[•] Downloading OneShot from GitHub...
[•] Creating launcher script...
[✓] Found interface: wlan0

╔═══════════════════════════════════════╗
║   Installation Complete! ✓            ║
╚═══════════════════════════════════════╝

Quick Start Guide:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Scan for vulnerable networks:
   oneshot -i wlan0 -S

2. Run Pixie Dust attack:
   oneshot -i wlan0 --iface-down -K

3. Attack specific network:
   oneshot -i wlan0 -b [BSSID] -K

⚠ WARNING: Only use on networks you own or have permission to test!
```

## 🔧 How It Works

1. **Downloads** - Pulls install.sh from your GitHub
2. **Executes** - Bash runs the script directly
3. **Installs** - All dependencies via pkg manager
4. **Clones** - Full repo to ~/oneshot
5. **Configures** - Creates wrapper in $PREFIX/bin
6. **Ready** - User can type `oneshot` anywhere

## 📋 Files Created by Installer

```
$HOME/oneshot/              # Main installation directory
├── oneshot.py              # Main Python script
├── vulnwsc.txt            # Vulnerability database
└── ...                     # Other repo files

$PREFIX/bin/oneshot         # Global command wrapper
```

## 🎯 Marketing Copy

Add this to your GitHub repo description:

> **OneShot** - WiFi WPS penetration testing tool for Termux
> 
> 🚀 **One-line install:**
> ```bash
> curl -sSfL https://raw.githubusercontent.com/zahidoverflow/oneshot/master/install.sh | bash
> ```
> 
> ✨ Features:
> - Pixie Dust attack
> - WPS PIN bruteforce
> - Network scanner
> - No monitor mode required
> - Fully automated setup

## ✅ Testing Checklist

Before users install, test:
- [ ] Script downloads correctly
- [ ] Root access check works
- [ ] All packages install
- [ ] Repo clones successfully
- [ ] Wrapper script functions
- [ ] Command works globally
- [ ] WiFi interface detected
- [ ] Instructions are clear

## 🐛 Troubleshooting Guide

### If install fails:
1. Check internet connection
2. Verify root access: `su`
3. Update Termux: `pkg update`
4. Manual install from QUICKSTART.md

### Common Issues:
- **No root**: User needs to root device first
- **Network error**: Check GitHub availability
- **Package errors**: Run `pkg update && pkg upgrade`
- **Permission denied**: Grant root when prompted

## 🎉 You're Done!

Your repository now has:
- ✅ Professional one-liner installer
- ✅ Comprehensive documentation
- ✅ User-friendly setup experience
- ✅ Global command availability
- ✅ Automatic dependency management

Users can go from zero to hacking in under 5 minutes! 🔥
