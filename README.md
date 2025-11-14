# 🎯 OneShot

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Linux-green.svg)](https://github.com/zahidoverflow/oneshot)
[![Python](https://img.shields.io/badge/Python-3.6%2B-blue.svg)](https://www.python.org/)

**OneShot** is a powerful WiFi WPS penetration testing tool that performs [Pixie Dust attacks](https://forums.kali.org/showthread.php?24286-WPS-Pixie-Dust-Attack-Offline-WPS-Attack) without requiring monitor mode. Designed for rooted Android devices running Termux and Linux systems.

---

## 🚀 Quick Start (Termux)

### One-Line Installation

Install OneShot with a single command on your rooted Android device:

```bash
curl -sSfL https://zahidoverflow.github.io/oneshot/install.sh | bash
```

### Usage

```bash
# Auto-scan and attack with Pixie Dust
sudo oneshot -i wlan0 --iface-down -K

# Attack specific network
sudo oneshot -i wlan0 -b AA:BB:CC:DD:EE:FF -K

# Get help
sudo oneshot --help
```

---

## ✨ Features

- 🔓 **Pixie Dust Attack** - Advanced WPS PIN recovery
- 🔢 **3WiFi PIN Generator** - Offline WPS PIN generation
- 💪 **Online Bruteforce** - WPS PIN bruteforce attack
- 📡 **Smart Scanner** - WiFi network scanner with vulnerability detection
- 🎯 **Embedded Database** - Built-in vulnerable device database
- 🌐 **System-Wide Access** - Works from any terminal on rooted Android
- 📦 **Zero Dependencies** - No external files required
- ⚡ **Fast Installation** - Smart dependency checking

---

## 📋 Requirements

### Rooted Android (Termux)
- **Root Access** (Magisk, KernelSU, or APatch)
- **Termux** (from F-Droid)
- **Python 3.6+**
- **Active WiFi Hardware**

### Linux Systems
- **Python 3.6+**
- **wpa_supplicant**
- **pixiewps**
- **iw** (wireless tools)
- **Root privileges**

---

## 🔧 Installation

### Termux (Android)

#### Automatic Installation (Recommended)

```bash
curl -sSfL https://zahidoverflow.github.io/oneshot/install.sh | bash
```

**What the installer does:**
- ✅ Verifies root access
- ✅ Installs all dependencies (Python, wpa_supplicant, pixiewps, iw)
- ✅ Installs Python modules (wcwidth)
- ✅ Clones OneShot from GitHub
- ✅ Creates global command wrapper
- ✅ Installs to `/data/adb/bin` for system-wide access
- ✅ Detects WiFi interface automatically

#### Manual Installation

```bash
# Install dependencies
pkg install -y root-repo
pkg install -y git tsu python wpa-supplicant pixiewps iw openssl
pip install wcwidth

# Clone repository
git clone --depth 1 https://github.com/zahidoverflow/oneshot.git
cd oneshot

# Run
sudo python3 oneshot.py -i wlan0 --iface-down -K
```

---

### Debian/Ubuntu

```bash
# Install dependencies
sudo apt install -y python3 python3-pip wpasupplicant iw wget pixiewps

# Install Python module
pip3 install wcwidth

# Download OneShot
git clone --depth 1 https://github.com/zahidoverflow/oneshot.git
cd oneshot

# Run
sudo python3 oneshot.py -i wlan0 -K
```

---

### Arch Linux

```bash
# Install dependencies
sudo pacman -S wpa_supplicant pixiewps wget python python-pip iw

# Install Python module
pip install wcwidth

# Download OneShot
git clone --depth 1 https://github.com/zahidoverflow/oneshot.git
cd oneshot

# Run
sudo python3 oneshot.py -i wlan0 -K
```

---

## 📖 Usage Guide

### Basic Commands

```bash
# Run Pixie Dust attack (auto-scans networks)
sudo oneshot -i wlan0 --iface-down -K

# Attack specific BSSID
sudo oneshot -i wlan0 -b 00:90:4C:C1:AC:21 -K

# Online bruteforce with PIN
sudo oneshot -i wlan0 -b 00:90:4C:C1:AC:21 -B -p 1234

# WPS push button connection
sudo oneshot -i wlan0 --pbc

# Loop mode (continuous scanning)
sudo oneshot -i wlan0 -K -l
```

### Command-Line Options

```
Required:
  -i, --interface <wlan0>     : WiFi interface to use

Optional:
  -b, --bssid <mac>           : Target AP BSSID
  -p, --pin <wps pin>         : Use specific PIN (4/8 digits)
  -K, --pixie-dust            : Run Pixie Dust attack
  -B, --bruteforce            : Run online bruteforce
  --pbc                       : WPS push button connection

Advanced:
  -d, --delay <n>             : Delay between attempts [0]
  -w, --write                 : Save credentials to file
  -F, --pixie-force           : Force full Pixiewps range
  -X, --show-pixie-cmd        : Show Pixiewps command
  --vuln-list <file>          : Custom vulnerability list
  --iface-down                : Shutdown interface on exit
  -l, --loop                  : Run in loop mode
  -r, --reverse-scan          : Reverse network order
  --mtk-wifi                  : MediaTek WiFi driver support
  -v, --verbose               : Verbose output
```

---

## 🛡️ Security & Legal

### ⚠️ Important Warning

**This tool is for educational and authorized security testing purposes only.**

- ✅ **Legal Use:** Testing your own networks or with explicit permission
- ✅ **Security Research:** Authorized penetration testing
- ✅ **Educational:** Learning about WiFi security vulnerabilities
- ❌ **Illegal Use:** Unauthorized access to networks you don't own

**Unauthorized access to computer networks is illegal** in most countries. The developers assume **no liability** for misuse of this tool.

---

## 🐛 Troubleshooting

### Permission Denied

```bash
# Grant root permissions
su

# Or use sudo
sudo oneshot -i wlan0 -K
```

### WiFi Interface Not Found

```bash
# List available interfaces
sudo iw dev

# Use correct interface name
sudo oneshot -i wlan1 -K
```

### Python Module Missing

```bash
# Reinstall with dependencies
curl -sSfL https://zahidoverflow.github.io/oneshot/install.sh | bash
```

### RTNETLINK Error

```bash
# Unblock WiFi
sudo rfkill unblock wifi

# Or disable WiFi in settings and use --iface-down
sudo oneshot -i wlan0 --iface-down -K
```

### MediaTek WiFi Issues

```bash
# Use MTK driver support
sudo oneshot -i wlan0 --mtk-wifi -K
```

---

## 🔄 Updates

### Update OneShot

```bash
cd ~/oneshot
git pull origin master
```

### Reinstall

```bash
curl -sSfL https://zahidoverflow.github.io/oneshot/install.sh | bash
```

### Uninstall

```bash
# Remove files
rm -rf ~/oneshot
rm $PREFIX/bin/oneshot

# Remove system binary (rooted Android)
sudo rm /data/adb/bin/oneshot
```

---

## 🏗️ Architecture

### Key Components

- **WPS PIN Generator** - Multiple algorithm support (24-bit, 28-bit, 32-bit, vendor-specific)
- **Pixie Dust Engine** - Offline WPS PIN recovery using Pixiewps
- **Network Scanner** - iw-based WiFi network detection
- **Vulnerability Database** - Embedded list of 160+ vulnerable router models
- **WPA Supplicant Interface** - Direct WPS protocol implementation

### Supported Algorithms

- **24-bit PIN**, **28-bit PIN**, **32-bit PIN**
- **D-Link PIN**, **ASUS PIN**, **Airocon PIN**
- **Broadcom** (6 variants), **Realtek** (3 variants)
- **Cisco**, **Thomson**, **Edimax**, **Upvel**
- Static PINs for specific vendors

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
git clone https://github.com/zahidoverflow/oneshot.git
cd oneshot
python3 oneshot.py -i wlan0 -K -v
```

### Reporting Issues

Please include:
- Device/OS information
- Complete error message
- Steps to reproduce
- Output with `-v` (verbose) flag

---

## 📚 Additional Resources

- **Documentation:** [QUICKSTART.md](QUICKSTART.md)
- **Installer Guide:** [INSTALLER-README.md](INSTALLER-README.md)
- **Original Project:** [drygdryg/OneShot](https://github.com/drygdryg/OneShot)
- **Pixiewps:** [wiire-a/pixiewps](https://github.com/wiire-a/pixiewps)

---

## 👥 Credits

### Original Authors
- **rofl0r** - Initial OneShot implementation (2017)
- **drygdryg** - Major enhancements and improvements
- **Wiire** - Pixiewps development

### This Fork
- **zahidoverflow** - Termux optimization, one-liner installer, system-wide installation

### Special Thanks
- **Monohrom** - Testing and bug reports
- **Termux Team** - Android terminal environment
- **Magisk/KernelSU** - Root management frameworks

---

## 📜 License

This project is licensed under the **MIT License** - see below for details.

```
MIT License

Copyright (c) 2025 zahidoverflow
Original work Copyright (c) 2017 rofl0r

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🔗 Links

- **GitHub Repository:** https://github.com/zahidoverflow/oneshot
- **Issues:** https://github.com/zahidoverflow/oneshot/issues
- **Discussions:** https://github.com/zahidoverflow/oneshot/discussions

---

## 📊 Statistics

- **160+ Vulnerable Router Models** in embedded database
- **30+ WPS PIN Algorithms** supported
- **Zero External Dependencies** for operation
- **System-Wide Installation** on rooted Android

---

<div align="center">

### ⭐ Star this repository if you find it useful!

**Made with ❤️ for the security research community**

</div>

---

**Disclaimer:** Use this tool responsibly and ethically. Always obtain proper authorization before testing network security. The authors and contributors are not responsible for any misuse or damage caused by this tool.
