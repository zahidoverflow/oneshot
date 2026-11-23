#!/usr/bin/env bash
# OneShot Universal Installer - One-Line Setup Script for Termux & Generic Linux
# Usage: curl -fsSL https://zahidoverflow.github.io/oneshot/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║     OneShot Installer by @zahidoverflow        ║"
echo "║        WiFi Penetration Testing Tool           ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Detect Environment
IS_TERMUX=false
if [ -d "/data/data/com.termux" ] || [ -n "$TERMUX_VERSION" ]; then
    IS_TERMUX=true
fi

# Determine target home directory
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi

# Privilege Escalation Helper
run_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo &>/dev/null; then
        sudo "$@"
    elif command -v su &>/dev/null; then
        su -c "$*"
    else
        echo -e "${RED}[✗] Error: Privilege escalation required but neither sudo nor su was found.${NC}"
        exit 1
    fi
}

# Check Root Access / Privileges
echo -e "${YELLOW}[•] Checking system privileges${NC}"
if [ "$IS_TERMUX" = true ]; then
    if ! command -v su &>/dev/null && ! command -v tsu &>/dev/null; then
        echo -e "${RED}[✗] Root access tool (su/tsu) not found in Termux. Please root your device.${NC}"
        exit 1
    fi
    if su -c "exit" 2>/dev/null || tsu -c "exit" 2>/dev/null; then
        echo -e "${GREEN}[✓] Root access confirmed (Termux)${NC}"
    else
        echo -e "${RED}[✗] Root access denied in Termux.${NC}"
        exit 1
    fi
else
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${GREEN}[✓] Running as root${NC}"
    elif command -v sudo &>/dev/null; then
        if sudo -v 2>/dev/null || sudo -n true 2>/dev/null || [ -t 0 ]; then
            echo -e "${GREEN}[✓] Sudo access available${NC}"
        else
            echo -e "${YELLOW}[!] Sudo authentication required${NC}"
        fi
    else
        echo -e "${RED}[✗] Root privileges or sudo access are required to install dependencies and run OneShot.${NC}"
        exit 1
    fi
fi

# Show download size confirmation
show_download_confirmation() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}[•] Download Size Approx : ${GREEN}50MB - 120MB${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}The installer will set up:${NC}"
    echo -e "  ${BLUE}•${NC} Core tools (python, git, wget, curl)"
    echo -e "  ${BLUE}•${NC} WiFi tools (wpa_supplicant, pixiewps, iw)"
    echo -e "  ${BLUE}•${NC} Security tools (openssl)"
    echo -e "  ${BLUE}•${NC} Python modules (wcwidth)"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Proceeding with installation...${NC}"
}

show_download_confirmation

# Package Installation
echo -e "${YELLOW}[•] Detecting package manager and installing dependencies${NC}"

install_packages() {
    if [ "$IS_TERMUX" = true ]; then
        echo -e "${BLUE}→ Environment: Termux${NC}"
        pkg update -y || true
        pkg install -y root-repo 2>/dev/null || true
        local termux_pkgs=("tsu" "python" "git" "wget" "curl" "wpa-supplicant" "pixiewps" "iw" "openssl")
        local to_install=()
        for pkg in "${termux_pkgs[@]}"; do
            if pkg list-installed 2>/dev/null | grep -q "^${pkg}/"; then
                echo -e "${GREEN}  ✓ $pkg already installed${NC}"
            else
                to_install+=("$pkg")
            fi
        done
        if [ ${#to_install[@]} -gt 0 ]; then
            echo -e "${BLUE}  → Installing missing packages: ${to_install[*]}${NC}"
            pkg install -y "${to_install[@]}" 2>&1 | grep -v "Warning" || true
        fi
    elif command -v apt-get &>/dev/null; then
        echo -e "${BLUE}→ Package Manager: apt (Debian/Ubuntu/Kali/Parrot/Mint)${NC}"
        run_root apt-get -o Dpkg::Lock::Timeout=60 update -y || true
        local apt_pkgs=("python3" "python3-pip" "python3-wcwidth" "git" "wget" "curl" "wpasupplicant" "pixiewps" "iw" "openssl")
        local to_install=()
        for pkg in "${apt_pkgs[@]}"; do
            if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
                echo -e "${GREEN}  ✓ $pkg already installed${NC}"
            else
                to_install+=("$pkg")
            fi
        done
        if [ ${#to_install[@]} -gt 0 ]; then
            echo -e "${BLUE}  → Installing missing packages: ${to_install[*]}${NC}"
            run_root apt-get -o Dpkg::Lock::Timeout=60 install -y "${to_install[@]}" || echo -e "${YELLOW}  ! Package installation completed with warnings${NC}"
        fi
    elif command -v pacman &>/dev/null; then
        echo -e "${BLUE}→ Package Manager: pacman (Arch/Manjaro)${NC}"
        run_root pacman -Sy --noconfirm || true
        local pacman_pkgs=("python" "python-pip" "python-wcwidth" "git" "wget" "curl" "wpa_supplicant" "pixiewps" "iw" "openssl")
        local to_install=()
        for pkg in "${pacman_pkgs[@]}"; do
            if pacman -Q "$pkg" &>/dev/null; then
                echo -e "${GREEN}  ✓ $pkg already installed${NC}"
            else
                to_install+=("$pkg")
            fi
        done
        if [ ${#to_install[@]} -gt 0 ]; then
            echo -e "${BLUE}  → Installing missing packages: ${to_install[*]}${NC}"
            run_root pacman -S --noconfirm "${to_install[@]}" || echo -e "${YELLOW}  ! Package installation completed with warnings${NC}"
        fi
    elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
        local pm="dnf"
        command -v dnf &>/dev/null || pm="yum"
        echo -e "${BLUE}→ Package Manager: $pm (Fedora/RHEL/CentOS)${NC}"
        local redhat_pkgs=("python3" "python3-pip" "python3-wcwidth" "git" "wget" "curl" "wpa_supplicant" "pixiewps" "iw" "openssl")
        local to_install=()
        for pkg in "${redhat_pkgs[@]}"; do
            if rpm -q "$pkg" &>/dev/null; then
                echo -e "${GREEN}  ✓ $pkg already installed${NC}"
            else
                to_install+=("$pkg")
            fi
        done
        if [ ${#to_install[@]} -gt 0 ]; then
            echo -e "${BLUE}  → Installing missing packages: ${to_install[*]}${NC}"
            run_root $pm install -y "${to_install[@]}" || echo -e "${YELLOW}  ! Package installation completed with warnings${NC}"
        fi
    elif command -v apk &>/dev/null; then
        echo -e "${BLUE}→ Package Manager: apk (Alpine)${NC}"
        run_root apk update || true
        local alpine_pkgs=("python3" "py3-pip" "py3-wcwidth" "git" "wget" "curl" "wpa_supplicant" "pixiewps" "iw" "openssl")
        local to_install=()
        for pkg in "${alpine_pkgs[@]}"; do
            if apk info -e "$pkg" &>/dev/null; then
                echo -e "${GREEN}  ✓ $pkg already installed${NC}"
            else
                to_install+=("$pkg")
            fi
        done
        if [ ${#to_install[@]} -gt 0 ]; then
            echo -e "${BLUE}  → Installing missing packages: ${to_install[*]}${NC}"
            run_root apk add "${to_install[@]}" || echo -e "${YELLOW}  ! Package installation completed with warnings${NC}"
        fi
    elif command -v zypper &>/dev/null; then
        echo -e "${BLUE}→ Package Manager: zypper (openSUSE)${NC}"
        local suse_pkgs=("python3" "python3-pip" "python3-wcwidth" "git" "wget" "curl" "wpa_supplicant" "pixiewps" "iw" "openssl")
        local to_install=()
        for pkg in "${suse_pkgs[@]}"; do
            if rpm -q "$pkg" &>/dev/null; then
                echo -e "${GREEN}  ✓ $pkg already installed${NC}"
            else
                to_install+=("$pkg")
            fi
        done
        if [ ${#to_install[@]} -gt 0 ]; then
            echo -e "${BLUE}  → Installing missing packages: ${to_install[*]}${NC}"
            run_root zypper install -y "${to_install[@]}" || echo -e "${YELLOW}  ! Package installation completed with warnings${NC}"
        fi
    else
        echo -e "${YELLOW}  ! Unknown package manager. Skipping automatic system package installation.${NC}"
        echo -e "${YELLOW}  ! Please ensure python3, git, wpa_supplicant, pixiewps, and iw are installed.${NC}"
    fi
}

install_packages

# Python dependencies verification for root / system environment
echo -e "${YELLOW}[•] Verifying Python dependencies (system-wide & root)${NC}"
if run_root python3 -c "import wcwidth" 2>/dev/null; then
    echo -e "${GREEN}  ✓ wcwidth is installed and accessible to root${NC}"
else
    echo -e "${BLUE}  → Installing wcwidth system-wide for root Python environment${NC}"
    run_root python3 -m pip install wcwidth --break-system-packages 2>/dev/null || \
    run_root pip3 install wcwidth 2>/dev/null || \
    run_root pip3 install --break-system-packages wcwidth 2>/dev/null || \
    pip3 install wcwidth 2>/dev/null || \
    pip install wcwidth 2>/dev/null || \
    echo -e "${YELLOW}  ! Could not install wcwidth automatically. Please run 'sudo pip install wcwidth' manually.${NC}"
fi

# Check pixiewps availability
if command -v pixiewps &>/dev/null; then
    echo -e "${GREEN}[✓] pixiewps binary is available${NC}"
else
    echo -e "${YELLOW}[!] Note: pixiewps not found. Pixie Dust mode (-K) requires pixiewps.${NC}"
    echo -e "${YELLOW}    (Source: https://github.com/wiire-a/pixiewps)${NC}"
fi

# Set installation directory
if [ -f "./oneshot.py" ]; then
    INSTALL_DIR="$(pwd)"
    echo -e "${GREEN}[✓] Using current directory: $INSTALL_DIR${NC}"
else
    INSTALL_DIR="$USER_HOME/oneshot"
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}[•] Updating existing installation in $INSTALL_DIR${NC}"
        if [ -d "$INSTALL_DIR/.git" ]; then
            (cd "$INSTALL_DIR" && git fetch --depth 1 origin main && git reset --hard origin/main) || \
            (cd "$INSTALL_DIR" && git pull) || true
        fi
    else
        echo -e "${YELLOW}[•] Downloading OneShot from GitHub${NC}"
        git clone --depth 1 --branch main https://github.com/zahidoverflow/oneshot.git "$INSTALL_DIR"
    fi
fi

# Verify oneshot.py
ONESHOT_SCRIPT="$INSTALL_DIR/oneshot.py"
if [ -f "$ONESHOT_SCRIPT" ]; then
    echo -e "${GREEN}[✓] OneShot script verified at $ONESHOT_SCRIPT${NC}"
    chmod +x "$ONESHOT_SCRIPT"
else
    echo -e "${RED}[✗] Error: oneshot.py not found at $ONESHOT_SCRIPT${NC}"
    exit 1
fi

# Interface Detection
echo -e "${YELLOW}[•] Detecting wireless interface${NC}"
detect_interface() {
    local iface=""
    local iw_out=""
    local iw_bin=""

    if command -v iw &>/dev/null; then
        iw_bin=$(command -v iw)
        iw_out=$("$iw_bin" dev 2>/dev/null || true)
        [ -z "$iw_out" ] && iw_out=$(run_root "$iw_bin" dev 2>/dev/null || true)
    fi

    if [ -n "$iw_out" ]; then
        iface=$(printf '%s\n' "$iw_out" | awk '
            /^[[:space:]]*Interface[[:space:]]+/ {
                if (cur != "" && !excl && (ctype == "managed" || ctype == "")) {
                    if (cur == "wlan0") { print cur; found = 1; exit }
                    if (best == "" || (cur ~ /^wlan/ && best !~ /^wlan/) || (cur ~ /^wlan/ && best ~ /^wlan/ && cur < best)) best = cur
                }
                cur = $2
                ctype = ""
                excl = (cur ~ /^(p2p|ap[0-9]|swlan|softap|aware|nan|mon[0-9])/)
                next
            }
            /^[[:space:]]*type[[:space:]]+/ && cur != "" {
                ctype = tolower($2)
            }
            END {
                if (!found) {
                    if (cur != "" && !excl && (ctype == "managed" || ctype == "")) {
                        if (cur == "wlan0") best = cur
                        else if (best == "" || (cur ~ /^wlan/ && best !~ /^wlan/) || (cur ~ /^wlan/ && best ~ /^wlan/ && cur < best)) best = cur
                    }
                    if (best != "") print best
                }
            }
        ')
    fi

    if [ -z "$iface" ] && [ -d "/sys/class/net" ]; then
        iface=$(ls /sys/class/net 2>/dev/null | grep -E '^(wlan|wlp|wlx)' | grep -Ev '^(p2p|ap[0-9]|swlan|softap|aware|nan|mon[0-9])' | sort -V | head -n 1)
    fi

    if [ -z "$iface" ] && command -v ip &>/dev/null; then
        iface=$(ip link 2>/dev/null | awk -F': ' '/^[0-9]+: (wlan|wlp|wlx)/ {print $2}' | cut -d'@' -f1 | grep -Ev '^(p2p|ap[0-9]|swlan|softap|aware|nan|mon[0-9])' | sort -V | head -n 1)
    fi

    [ -z "$iface" ] && iface="wlan0"
    echo "$iface"
}

WLAN_INTERFACE=$(detect_interface)
echo -e "${GREEN}[✓] Target wireless interface: $WLAN_INTERFACE${NC}"

# Binary/Launcher directory
echo -e "${YELLOW}[•] Creating launcher script${NC}"
if [ "$IS_TERMUX" = true ]; then
    BIN_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
else
    if [ -w "/usr/local/bin" ] || [ "$(id -u)" -eq 0 ] || command -v sudo &>/dev/null; then
        BIN_DIR="/usr/local/bin"
    else
        BIN_DIR="$USER_HOME/.local/bin"
        mkdir -p "$BIN_DIR"
    fi
fi

LAUNCHER="$BIN_DIR/oneshot"
if [ "$IS_TERMUX" = true ]; then
    LAUNCHER_SHEBANG="#!${PREFIX:-/data/data/com.termux/files/usr}/bin/env bash"
else
    LAUNCHER_SHEBANG="#!/usr/bin/env bash"
fi

LAUNCHER_CONTENT=$(cat << WRAPPER
$LAUNCHER_SHEBANG
# OneShot Launcher Wrapper
SCRIPT_DIR="$INSTALL_DIR"
if [ -f "\$SCRIPT_DIR/oneshot.py" ]; then
    if [ \$(id -u) -ne 0 ]; then
        if command -v sudo &>/dev/null; then
            EXEC_CMD="sudo python3"
        elif command -v tsu &>/dev/null; then
            EXEC_CMD="tsu python3"
        else
            EXEC_CMD="python3"
        fi
    else
        EXEC_CMD="python3"
    fi

    if [ \$# -eq 0 ]; then
        # Default action: Auto-detect interface at runtime and run Pixie Dust scan
        \$EXEC_CMD "\$SCRIPT_DIR/oneshot.py" -K
    else
        # Pass through all arguments
        \$EXEC_CMD "\$SCRIPT_DIR/oneshot.py" "\$@"
    fi
else
    echo "Error: oneshot.py not found in \$SCRIPT_DIR"
    exit 1
fi
WRAPPER
)

if [ -w "$(dirname "$LAUNCHER")" ]; then
    echo "$LAUNCHER_CONTENT" > "$LAUNCHER"
    chmod +x "$LAUNCHER"
else
    echo "$LAUNCHER_CONTENT" | run_root tee "$LAUNCHER" > /dev/null
    run_root chmod +x "$LAUNCHER"
fi

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║        Installation complete              ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Quick Start Guide:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}1. Instant scan & Pixie Dust attack (auto-detects interface):${NC}"
echo -e "   ${GREEN}oneshot${NC}"
echo ""
echo -e "${YELLOW}2. Attack specific BSSID:${NC}"
echo -e "   ${GREEN}oneshot -i $WLAN_INTERFACE -b [MAC] -K${NC}"
echo ""
echo -e "${YELLOW}3. Get help:${NC}"
echo -e "   ${GREEN}oneshot -h${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Installation Path:${NC} $INSTALL_DIR"
echo -e "${YELLOW}Launcher Path:${NC} $LAUNCHER"
echo -e "${YELLOW}WiFi Interface:${NC} $WLAN_INTERFACE"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║ WARNING: Only use on authorized networks! ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"