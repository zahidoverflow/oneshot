#!/data/data/com.termux/files/usr/bin/bash
# OneShot Termux Installer - One-Line Setup Script
# Usage: curl -sSfL https://zahidoverflow.github.io/oneshot/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║     OneShot Termux Installer v1.0    ║"
echo "║   WiFi WPS Penetration Testing Tool  ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[✗] Error: This script must be run in Termux!${NC}"
    exit 1
fi

# Check for root access
echo -e "${YELLOW}[•] Checking root access...${NC}"
if ! command -v su &> /dev/null; then
    echo -e "${RED}[✗] Root access not available. Please root your device first.${NC}"
    exit 1
fi

# Test root access
if su -c "exit" 2>/dev/null; then
    echo -e "${GREEN}[✓] Root access confirmed${NC}"
else
    echo -e "${RED}[✗] Root access denied. Please grant root permissions.${NC}"
    exit 1
fi

# Update packages
echo -e "${YELLOW}[•] Updating package lists...${NC}"
pkg update -y || true

# Install root repository
echo -e "${YELLOW}[•] Installing root repository...${NC}"
pkg install -y root-repo 2>/dev/null || true

# Install dependencies
echo -e "${YELLOW}[•] Checking and installing dependencies...${NC}"
PACKAGES=(
    "tsu"
    "python"
    "git"
    "wget"
    "curl"
    "wpa-supplicant"
    "pixiewps"
    "iw"
    "openssl"
)

for package in "${PACKAGES[@]}"; do
    if pkg list-installed 2>/dev/null | grep -q "^${package}/"; then
        echo -e "${GREEN}  ✓ $package already installed${NC}"
    else
        echo -e "${BLUE}  → Installing $package...${NC}"
        pkg install -y "$package" 2>&1 | grep -v "Warning" || true
    fi
done

# Set installation directory
INSTALL_DIR="$HOME/oneshot"

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[•] Removing old installation...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Clone OneShot repository
echo -e "${YELLOW}[•] Downloading OneShot from GitHub...${NC}"
git clone --depth 1 --branch master https://github.com/zahidoverflow/oneshot.git "$INSTALL_DIR"

# Verify oneshot.py exists
echo -e "${YELLOW}[•] Verifying installation...${NC}"
cd "$INSTALL_DIR"

ONESHOT_SCRIPT=""
if [ -f "$INSTALL_DIR/oneshot.py" ]; then
    ONESHOT_SCRIPT="$INSTALL_DIR/oneshot.py"
    echo -e "${GREEN}[✓] OneShot script found${NC}"
else
    echo -e "${RED}[✗] Error: oneshot.py not found in repository${NC}"
    echo -e "${RED}Please check your repository structure${NC}"
    exit 1
fi

# Make script executable
chmod +x "$ONESHOT_SCRIPT"

# Create convenience wrapper script for Termux
echo -e "${YELLOW}[•] Creating launcher scripts...${NC}"
cat > "$PREFIX/bin/oneshot" << 'WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
SCRIPT_DIR="$HOME/oneshot"
if [ -f "$SCRIPT_DIR/oneshot.py" ]; then
    sudo python3 "$SCRIPT_DIR/oneshot.py" "$@"
else
    echo "Error: oneshot.py not found in $SCRIPT_DIR"
    exit 1
fi
WRAPPER

chmod +x "$PREFIX/bin/oneshot"

# Install to system-wide location for all root managers (Magisk/KernelSU/APatch)
if [ -d "/data/adb" ]; then
    echo -e "${YELLOW}[•] Installing to system-wide location...${NC}"
    su -c "mkdir -p /data/adb/bin" 2>/dev/null || true
    
    # Create system-wide wrapper
    cat > /tmp/oneshot_system << 'SYSWRAPPER'
#!/system/bin/sh
SCRIPT_PATH="/data/data/com.termux/files/home/oneshot/oneshot.py"
PYTHON_PATH="/data/data/com.termux/files/usr/bin/python3"

if [ ! -f "$SCRIPT_PATH" ]; then
    SCRIPT_PATH="$HOME/oneshot/oneshot.py"
fi

if [ -f "$SCRIPT_PATH" ]; then
    if [ -x "$PYTHON_PATH" ]; then
        "$PYTHON_PATH" "$SCRIPT_PATH" "$@"
    elif command -v python3 >/dev/null 2>&1; then
        python3 "$SCRIPT_PATH" "$@"
    else
        echo "Error: Python 3 not found"
        exit 1
    fi
else
    echo "Error: oneshot.py not found"
    echo "Please run from Termux or ensure the script is installed"
    exit 1
fi
SYSWRAPPER
    
    su -c "cp /tmp/oneshot_system /data/adb/bin/oneshot && chmod 755 /data/adb/bin/oneshot" 2>/dev/null
    rm -f /tmp/oneshot_system
    
    if [ -f "/data/adb/bin/oneshot" ]; then
        echo -e "${GREEN}[✓] Installed to /data/adb/bin/oneshot (global access)${NC}"
    else
        echo -e "${YELLOW}[!] Could not install to /data/adb/bin (Termux-only access)${NC}"
    fi
else
    echo -e "${YELLOW}[!] /data/adb not found (non-standard root or Termux-only)${NC}"
fi

# Test wireless interface
echo -e "${YELLOW}[•] Detecting wireless interface...${NC}"
WLAN_INTERFACE=$(su -c "iw dev" 2>/dev/null | grep -oP 'Interface \K\w+' | head -1 || echo "wlan0")
echo -e "${GREEN}[✓] Found interface: $WLAN_INTERFACE${NC}"

# Installation complete
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! ✓            ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Quick Start Guide:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}1. Scan for vulnerable networks:${NC}"
echo -e "   ${GREEN}sudo oneshot -i $WLAN_INTERFACE -S${NC}"
echo ""
echo -e "${YELLOW}2. Run Pixie Dust attack:${NC}"
echo -e "   ${GREEN}sudo oneshot -i $WLAN_INTERFACE --iface-down -K${NC}"
echo ""
echo -e "${YELLOW}3. Attack specific network:${NC}"
echo -e "   ${GREEN}sudo oneshot -i $WLAN_INTERFACE -b [BSSID] -K${NC}"
echo ""
echo -e "${YELLOW}4. Get help:${NC}"
echo -e "   ${GREEN}sudo oneshot --help${NC}"
echo ""
if [ -f "/data/adb/bin/oneshot" ]; then
echo -e "${GREEN}[✓] Global access enabled - run 'oneshot' from any terminal!${NC}"
echo ""
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Installation Path:${NC} $INSTALL_DIR"
echo -e "${YELLOW}WiFi Interface:${NC} $WLAN_INTERFACE"
if [ -f "/data/adb/bin/oneshot" ]; then
echo -e "${YELLOW}System Binary:${NC} /data/adb/bin/oneshot"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${RED}⚠ WARNING: Only use on networks you own or have permission to test!${NC}"
echo ""
