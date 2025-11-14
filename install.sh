#!/data/data/com.termux/files/usr/bin/bash
# OneShot Termux Installer - One-Line Setup Script
# Usage: curl -sSfL https://raw.githubusercontent.com/zahidoverflow/oneshot/master/install.sh | bash

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
echo -e "${YELLOW}[•] Installing dependencies (this may take a few minutes)...${NC}"
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
    echo -e "${BLUE}  → Installing $package...${NC}"
    pkg install -y "$package" 2>&1 | grep -v "Warning" || true
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

# Download vulnerability database
echo -e "${YELLOW}[•] Downloading vulnerability database...${NC}"
cd "$INSTALL_DIR"
wget -q https://raw.githubusercontent.com/drygdryg/OneShot/master/vulnwsc.txt -O vulnwsc.txt 2>/dev/null || \
wget -q https://raw.githubusercontent.com/zahidoverflow/oneshot/master/vulnwsc.txt -O vulnwsc.txt 2>/dev/null || \
echo -e "${YELLOW}  → Vulnerability database not found (optional)${NC}"

# Find the Python script
ONESHOT_SCRIPT=""
if [ -f "$INSTALL_DIR/oneshot.py" ]; then
    ONESHOT_SCRIPT="$INSTALL_DIR/oneshot.py"
elif [ -f "$INSTALL_DIR/app/src/main/res/raw/oneshot_py" ]; then
    ONESHOT_SCRIPT="$INSTALL_DIR/app/src/main/res/raw/oneshot_py"
    # Create symlink for easier access
    ln -sf "$ONESHOT_SCRIPT" "$INSTALL_DIR/oneshot.py" 2>/dev/null || true
fi

# If no Python script found, download from original repo
if [ -z "$ONESHOT_SCRIPT" ] || [ ! -f "$ONESHOT_SCRIPT" ]; then
    echo -e "${YELLOW}[•] Python script not found, downloading from upstream...${NC}"
    wget -q https://raw.githubusercontent.com/drygdryg/OneShot/master/oneshot.py -O "$INSTALL_DIR/oneshot.py"
    ONESHOT_SCRIPT="$INSTALL_DIR/oneshot.py"
fi

# Make script executable
chmod +x "$ONESHOT_SCRIPT"

# Create convenience wrapper script
echo -e "${YELLOW}[•] Creating launcher script...${NC}"
cat > "$PREFIX/bin/oneshot" << 'WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
SCRIPT_DIR="$HOME/oneshot"
if [ -f "$SCRIPT_DIR/oneshot.py" ]; then
    su -c "python $SCRIPT_DIR/oneshot.py $@"
else
    echo "Error: oneshot.py not found in $SCRIPT_DIR"
    exit 1
fi
WRAPPER

chmod +x "$PREFIX/bin/oneshot"

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
echo -e "   ${GREEN}oneshot -i $WLAN_INTERFACE -S${NC}"
echo ""
echo -e "${YELLOW}2. Run Pixie Dust attack:${NC}"
echo -e "   ${GREEN}oneshot -i $WLAN_INTERFACE --iface-down -K${NC}"
echo ""
echo -e "${YELLOW}3. Attack specific network:${NC}"
echo -e "   ${GREEN}oneshot -i $WLAN_INTERFACE -b [BSSID] -K${NC}"
echo ""
echo -e "${YELLOW}4. Get help:${NC}"
echo -e "   ${GREEN}oneshot --help${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Installation Path:${NC} $INSTALL_DIR"
echo -e "${YELLOW}WiFi Interface:${NC} $WLAN_INTERFACE"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${RED}⚠ WARNING: Only use on networks you own or have permission to test!${NC}"
echo ""
