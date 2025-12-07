# 🚀 OneShot Quick Start Guide

## One-Line Installation (Termux)

### For Rooted Android Devices

Simply run this single command in Termux:

```bash
curl -fsSL https://zahidoverflow.github.io/oneshot/install.sh | bash
```

That's it! The installer will:
- ✅ Check for root access
- ✅ Install all required dependencies (Python, wpa_supplicant, pixiewps, iw, etc.)
- ✅ Download OneShot from GitHub
- ✅ Download vulnerability database
- ✅ Detect your WiFi interface
- ✅ Create a convenient `oneshot` command

## Usage After Installation

### 1. Run Pixie Dust Attack (Auto-scan and Attack)
```bash
sudo oneshot -i wlan0 --iface-down -K
```

### 2. Attack Specific Network
```bash
sudo oneshot -i wlan0 -b AA:BB:CC:DD:EE:FF -K
```

### 3. Bruteforce Attack
```bash
sudo oneshot -i wlan0 -b AA:BB:CC:DD:EE:FF -B
```

### 4. Get Help
```bash
sudo oneshot --help
```

## Common Options

| Option | Description |
|--------|-------------|
| `-i wlan0` | Specify wireless interface |
| `-K` | Run Pixie Dust attack (auto-scans networks) |
| `-B` | Run online bruteforce attack |
| `-b BSSID` | Target specific network by BSSID |
| `--iface-down` | Don't bring interface down/up automatically |
| `-p PIN` | Use specific WPS PIN |
| `--pbc` | Use Push Button Configuration mode |

## Troubleshooting

### Root Access Denied
Make sure you grant root permissions when prompted:
```bash
su
```

### WiFi Interface Not Found
Check available interfaces:
```bash
su -c "iw dev"
```

### Permission Errors
Always run with proper root access:
```bash
su -c "python ~/oneshot/oneshot.py -i wlan0 -K"
```
Or use the wrapper:
```bash
sudo oneshot -i wlan0 -K
```

### Reinstall
```bash
curl -fsSL https://zahidoverflow.github.io/oneshot/install.sh | bash
```

## Manual Update

```bash
cd ~/oneshot
git pull origin master
```

## Uninstall

```bash
rm -rf ~/oneshot
rm $PREFIX/bin/oneshot
```

## ⚠️ Legal Warning

**Only use this tool on networks you own or have explicit permission to test.**

Unauthorized access to computer networks is illegal in most jurisdictions. This tool is intended for:
- Security research
- Penetration testing with permission
- Educational purposes
- Testing your own networks

## Requirements

- Rooted Android device
- Termux (from F-Droid)
- Active WiFi hardware
- Root permissions granted

## What Gets Installed

The one-liner installs:
- **Python 3** - Programming language runtime
- **tsu** - Root shell for Termux
- **wpa_supplicant** - WPA/WPA2 authentication
- **pixiewps** - Pixie Dust attack implementation
- **iw** - Wireless interface configuration
- **openssl** - Cryptographic functions
- **git** - Version control (for cloning)
- **wget/curl** - File downloading

## Network Interface Names

Common WiFi interface names:
- `wlan0` - Primary WiFi interface
- `wlan1` - Secondary WiFi interface
- `p2p0` - WiFi Direct interface

Use `iw dev` to list all interfaces.

## Success Rate

Success depends on:
- Router vulnerability to Pixie Dust
- WPS being enabled on target
- Signal strength
- Router model and firmware

Older routers are generally more vulnerable.

## Support

- GitHub Issues: https://github.com/zahidoverflow/oneshot/issues
- Original Project: https://github.com/drygdryg/OneShot

---

**Made easy for the security research community 🔒**
