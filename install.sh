#!/data/data/com.termux/files/usr/bin/bash
# OneShot Termux Installer - One-Line Setup Script
# Usage: curl -fsSL https://zahidoverflow.github.io/oneshot/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to calculate total download size
calculate_download_size() {
    local total_size=0
    local packages=("tsu" "python" "git" "wget" "curl" "wpa-supplicant" "pixiewps" "iw" "openssl")
    local packages_to_install=()
    
    echo -e "${YELLOW}[•] Measuring package sizes${NC}"
    
    # First pass: collect packages that need to be installed
    for package in "${packages[@]}"; do
        if pkg list-installed 2>/dev/null | grep -q "^${package}/"; then
            echo -e "${GREEN}  ✓ $package (already installed)${NC}"
        else
            packages_to_install+=("$package")
        fi
    done
    
    # Second pass: get actual sizes for packages to install
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        echo -e "${YELLOW}[•] Querying package repository${NC}"
        for package in "${packages_to_install[@]}"; do
            # Method 1: Try apt-cache (most reliable)
            local size=$(apt-cache show "$package" 2>/dev/null | grep "^Size:" | awk '{print $2}')
            
            if [ -z "$size" ] || [ "$size" = "0" ]; then
                # Method 2: Try pkg show for Termux packages
                size=$(pkg show "$package" 2>/dev/null | grep "Size:" | awk '{print $2}')
            fi
            
            if [ -n "$size" ] && [ "$size" != "0" ]; then
                total_size=$((total_size + size))
                echo -e "${BLUE}  ↓ $package: $(($size / 1024)) KB${NC}"
            fi
        done
    fi
    
    # Convert bytes to human readable format
    if [ $total_size -gt 0 ]; then
        if [ $total_size -ge 1048576 ]; then
            echo "$((total_size / 1048576)) MB"
        elif [ $total_size -ge 1024 ]; then
            echo "$((total_size / 1024)) KB"
        else
            echo "$total_size B"
        fi
    else
        echo "0 B"
    fi
}

# Function to show download confirmation
show_download_confirmation() {
    local download_size=$1
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}[•] Download Size Estimate:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Total packages size: $download_size${NC}"
    echo ""
    echo -e "${YELLOW}This will download and install:${NC}"
    echo "  • Core tools (python, git, wget, curl)"
    echo "  • WiFi tools (wpa-supplicant, pixiewps, iw)"
    echo "  • Security tools (openssl)"
    echo "  • Python dependencies (wcwidth)"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Proceeding with installation${NC}"
}

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║     OneShot Installer by @zahidoverflow        ║"
echo "║        WiFi Penetration Testing Tool           ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[✗] Error: This script must be run in Termux!${NC}"
    exit 1
fi

# Check for root access
echo -e "${YELLOW}[•] Checking root access${NC}"
if ! command -v su &> /dev/null; then
    echo -e "${RED}[x] Root access not available. Please root your device first.${NC}"
    exit 1
fi

# Test root access
if su -c "exit" 2>/dev/null; then
    echo -e "${GREEN}[•] Root access confirmed${NC}"
else
    echo -e "${RED}[x] Root access denied. Please grant root permissions.${NC}"
    exit 1
fi

# Show download size estimate before proceeding
ESTIMATED_SIZE=$(calculate_download_size)
show_download_confirmation "$ESTIMATED_SIZE"

# Update packages
echo -e "${YELLOW}[•] Updating package lists${NC}"
pkg update -y || true

# Install root repository
echo -e "${YELLOW}[•] Installing root repository${NC}"
pkg install -y root-repo 2>/dev/null || true

# Install dependencies
echo -e "${YELLOW}[•] Checking and installing dependencies${NC}"
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
        echo -e "${BLUE}  → Installing $package${NC}"
        pkg install -y "$package" 2>&1 | grep -v "Warning" || true
    fi
done

# Install Python dependencies
echo -e "${YELLOW}[•] Installing Python dependencies${NC}"
if python3 -c "import wcwidth" 2>/dev/null; then
    echo -e "${GREEN}  ✓ wcwidth already installed${NC}"
else
    echo -e "${BLUE}  → Installing wcwidth${NC}"
    pip install wcwidth 2>&1 | grep -v "WARNING" || true
fi

# Set installation directory
INSTALL_DIR="$HOME/oneshot"

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[•] Removing old installation${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Clone OneShot repository
echo -e "${YELLOW}[•] Downloading OneShot from GitHub${NC}"
git clone --depth 1 --branch main https://github.com/zahidoverflow/oneshot.git "$INSTALL_DIR"

# Verify oneshot.py exists
echo -e "${YELLOW}[•] Verifying installation${NC}"
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
echo -e "${YELLOW}[•] Creating launcher scripts${NC}"

# Get the actual user's home directory (not root's)
ACTUAL_HOME=$(eval echo ~${SUDO_USER:-$USER})
[ -z "$ACTUAL_HOME" ] && ACTUAL_HOME="$HOME"

cat > "$PREFIX/bin/oneshot" << WRAPPER
#!/data/data/com.termux/files/usr/bin/bash
# Use the actual installation directory, not root's home
SCRIPT_DIR="$INSTALL_DIR"
if [ -f "\$SCRIPT_DIR/oneshot.py" ]; then
    sudo python3 "\$SCRIPT_DIR/oneshot.py" "\$@"
else
    echo "Error: oneshot.py not found in \$SCRIPT_DIR"
    exit 1
fi
WRAPPER

chmod +x "$PREFIX/bin/oneshot"

# Test wireless interface
echo -e "${YELLOW}[•] Detecting wireless interface${NC}"
WLAN_INTERFACE=$(su -c "iw dev" 2>/dev/null | grep -oP 'Interface \K\w+' | head -1 || echo "wlan0")
echo -e "${GREEN}[✓] Found interface: $WLAN_INTERFACE${NC}"

# Installation complete
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete!              ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Quick Start Guide:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}1. Run Pixie Dust scan:${NC}"
echo -e "   ${GREEN}sudo oneshot -i $WLAN_INTERFACE -K${NC}"
echo ""
echo -e "${YELLOW}2. Attack specific BSSID:${NC}"
echo -e "   ${GREEN}sudo oneshot -i $WLAN_INTERFACE -b [MAC] -K${NC}"
echo ""
echo -e "${YELLOW}3. Get help:${NC}"
echo -e "   ${GREEN}sudo oneshot -h${NC}"
echo ""
# Note: system-wide installation disabled for safety (no writes to /data/adb)
# Global access messaging removed to avoid suggesting system installs

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Installation Path:${NC} $INSTALL_DIR"
echo -e "${YELLOW}WiFi Interface:${NC} $WLAN_INTERFACE"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo ""
# Warning
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║ WARNING: Only use on authorized networks! ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"