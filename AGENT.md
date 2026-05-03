# OneShot — AI Agent Context

## Project Summary
WiFi WPS penetration testing tool (Python 3.6+). Performs **Pixie Dust** (offline WPS PIN recovery) and **online bruteforce** attacks without requiring monitor mode. Designed for rooted Android (Termux) and Linux systems.

**Repo:** `zahidoverflow/oneshot` — fork of `drygdryg/OneShot` (original: `rofl0r`)

---

## File Map

| File | Purpose |
|---|---|
| `oneshot.py` | Single-file main application (~1505 lines) |
| `install.sh` | Termux one-liner installer (Bash, ~290 lines) |
| `vulnwsc.txt` | External vulnerable device list (fallback to embedded DB) |
| `README.md` | Full project documentation |
| `.flake8` | Linting config |

---

## Core Classes (`oneshot.py`)

### `NetworkAddress` (L22–88)
MAC address wrapper with int/string dual representation. Supports arithmetic operators for PIN generation algorithms.

### `WPSpin` (L91–313)
WPS PIN generator. Key methods:
- `generate(algo, mac)` → 8-digit PIN string
- `getSuggested(mac)` → list of algorithm matches for a given MAC OUI
- `getLikely(mac)` → single best PIN guess
- `_suggest(mac)` → internal OUI-to-algorithm lookup table (hardcoded dict, ~30 algos)
- `checksum(pin)` → standard WPS 8th-digit checksum

**Algorithms:** `pin24`, `pin28`, `pin32`, `pinDLink`, `pinDLink1`, `pinASUS`, `pinAirocon`, `pinEmpty`, `pinCisco`, `pinBrcm1–6`, `pinAirc1–2`, `pinDSL2740R`, `pinRealtek1–3`, `pinUpvel`, `pinUR814AC`, `pinUR825AC`, `pinOnlime`, `pinEdimax`, `pinThomson`, `pinHG532x`, `pinH108L`, `pinONO`

### `PixiewpsData` (L332–355)
Holds cryptographic material extracted from WPS handshake for Pixiewps:
- Fields: `pke`, `pkr`, `e_hash1`, `e_hash2`, `authkey`, `e_nonce`
- `got_all()` — validates all fields present
- `get_pixie_cmd(full_range)` — builds the `pixiewps` CLI command string

### `ConnectionStatus` (L358–369)
Tracks wpa_supplicant session state. Status values: `WSC_NACK`, `WPS_FAIL`, `GOT_PSK`, `scanning`, `authenticating`, `associating`, `eapol_start`

### `BruteforceStatus` (L372–402)
Tracks bruteforce session progress. Saves/restores session state by writing current `mask` to `~/.OneShot/sessions/<BSSID>.run`.

### `Companion` (L405–851) — **Main Engine**
Orchestrates WPS attacks via wpa_supplicant Unix domain socket control interface.

**Init:** Spawns `wpa_supplicant` subprocess with `-K -d -Dnl80211,wext,hostapd,wired` flags; waits for control socket at `{tempdir}/{interface}`.

**Key methods:**
- `single_connection(bssid, pin, pixiemode, ...)` — executes one WPS attempt
- `smart_bruteforce(bssid, start_pin, delay)` — two-phase bruteforce (first half 0000–9999, second half 000–999); session-resumable
- `__wps_connection(bssid, pin, pixiemode, pbc_mode)` — sends `WPS_REG` or `WPS_PBC` to wpa_supplicant, polls stdout
- `__handle_wpas(...)` — parses wpa_supplicant stdout line-by-line to extract Pixiewps data and connection events
- `__runPixiewps(showcmd, full_range)` — invokes `pixiewps` binary, parses PIN from stdout
- `__saveResult(bssid, essid, wps_pin, wpa_psk)` — writes to `reports/stored.txt` and `reports/stored.csv`
- `__savePin(bssid, pin)` — saves Pixiewps-recovered PIN to `~/.OneShot/pixiewps/<BSSID>.run`
- `cleanup()` — closes socket, terminates wpas, removes temp files

**Storage paths:**
- Sessions: `~/.OneShot/sessions/`
- Pixiewps PINs: `~/.OneShot/pixiewps/`
- Reports: `<script_dir>/reports/`

### `WiFiScanner` (L854–1124)
Runs `iw dev <iface> scan`, parses output with regex matchers into network dicts. Filters WPS-enabled networks, sorts by signal, color-codes output (green=vulnerable, red=WPS-locked, yellow=already-cracked). Uses `wcwidth` for Unicode-aware column truncation.

**Network fields:** `BSSID`, `ESSID`, `Level`, `Security type`, `WPS`, `WPS locked`, `Model`, `Model number`, `Device name`

---

## CLI Arguments (`__main__`, L1179–1334)

| Flag | Type | Description |
|---|---|---|
| `-i / --interface` | str (required) | WiFi interface |
| `-b / --bssid` | str | Target AP MAC |
| `-p / --pin` | str | Specific PIN to try |
| `-K / --pixie-dust` | bool | Pixie Dust attack mode |
| `-B / --bruteforce` | bool | Online bruteforce mode |
| `--pbc` | bool | WPS Push Button Connection |
| `-F / --pixie-force` | bool | Pass `--force` to pixiewps |
| `-X / --show-pixie-cmd` | bool | Print pixiewps command |
| `-d / --delay` | float | Delay between attempts |
| `-w / --write` | bool | Save credentials to file |
| `--iface-down` | bool | Bring interface down on exit |
| `--vuln-list` | str | Path to vuln device list (default: `vulnwsc.txt`) |
| `-l / --loop` | bool | Loop mode (rescan after success/abort) |
| `-r / --reverse-scan` | bool | Reverse network list order |
| `--mtk-wifi` | bool | MediaTek driver activation (`/dev/wmtWifi`) |
| `-v / --verbose` | bool | Debug output to stderr |

**Startup checks:** Python ≥ 3.6, `os.getuid() == 0` (root required)

---

## Embedded Vulnerability Database (`VULN_DATABASE`, L1343–1504)
~160 router model strings embedded at EOF. Loaded if `vulnwsc.txt` is missing. Includes: TP-Link Archer series, ASUS RT-xx, D-Link DIR/DAP, Netgear, Tenda, Zyxel, Huawei, Keenetic, Linksys, Ralink RT2860-based devices.

---

## Installer (`install.sh`)
- **Target:** Termux on rooted Android only (checks `/data/data/com.termux`)
- **Root check:** Tests `su -c "exit"`
- **Packages:** `tsu python git wget curl wpa-supplicant pixiewps iw openssl`
- **Python dep:** `wcwidth` via pip
- **Install path:** `~/oneshot/` (cloned from GitHub main)
- **Termux wrapper:** `$PREFIX/bin/oneshot` → `sudo python3 ~/oneshot/oneshot.py "$@"`
- **System-wide installation:** Disabled for safety (no `/data/adb/bin` writes)

---

## Dependencies

| Dependency | Role |
|---|---|
| `wpa_supplicant` | WPS protocol implementation; controlled via Unix socket |
| `pixiewps` | Offline Pixie Dust cracking binary |
| `iw` | WiFi network scanning |
| `wcwidth` (pip) | Unicode display-width calculation for table rendering |
| `tsu` (Termux) | `sudo` equivalent for Termux root |

**Python stdlib used:** `sys`, `subprocess`, `os`, `tempfile`, `shutil`, `re`, `codecs`, `socket`, `pathlib`, `time`, `datetime`, `collections`, `statistics`, `csv`, `argparse`

---

## Key Design Patterns
- **No monitor mode needed** — uses wpa_supplicant `WPS_REG` command directly
- **Session resumability** — bruteforce and Pixiewps PIN states are written to disk
- **Embedded DB fallback** — `VULN_DATABASE` string at EOF loaded if external file missing
- **Single-file distribution** — entire tool is `oneshot.py`, no package structure
- **Zero external Python deps** (except `wcwidth`)

---

## Common Development Tasks

**Add a new PIN algorithm:**
1. Add lambda/method to `WPSpin.algos` dict
2. Add OUI prefixes to `WPSpin._suggest()` algorithms dict
3. Set `mode` to `ALGO_MAC`, `ALGO_STATIC`, or `ALGO_EMPTY`

**Add a vulnerable device:**
- Append model string to `VULN_DATABASE` (EOF of `oneshot.py`) and/or `vulnwsc.txt`

**Modify wpa_supplicant parsing:**
- Edit `Companion.__handle_wpas()` — line-by-line stdout parser

**Extend scan output:**
- Edit `WiFiScanner.iw_scanner()` — add regex to `matchers` dict and handler function
