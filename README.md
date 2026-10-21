<h3 align="center">VOID//ANON — Unified Anonymity Toolkit (Made in 2026)</h3>

<p align="center">
  A single Bash script combining Tor routing and MAC address changing.<br>
  Built for researchers who need both tools without installing three separate utilities.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/VOID-ANON-red?style=for-the-badge&logo=torproject&logoColor=white" alt="VoidAnon"/>
  <img src="https://img.shields.io/badge/Bash-Shell%20Script-green?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License"/>
  <img src="https://img.shields.io/badge/Made%20in-2026-purple?style=for-the-badge" alt="2026"/>
</p>

<p align="center">
  <b>Made by</b> heavén ·
  <a href="https://t.me/he6ca">DM</a>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Commands Reference](#commands-reference)
- [How It Works](#how-it-works)
- [What This Tool Does Not Do](#what-this-tool-does-not-do)
- [Project Structure](#project-structure)
- [Legal Disclaimer](#legal-disclaimer)
- [Contact](#contact)

---

## Overview

**VOID//ANON** is a single-file Bash script that combines two common research utilities into one interface:

1. **Tor routing** — sends any command through the Tor network with exit verification
2. **MAC address changing** — random, vendor-valid, or custom MAC with automatic backup and restore

Both operations are legitimate, documented, and used by real security researchers and privacy-conscious users. The script wraps standard tools (`torsocks`, `ip`, `macchanger`) rather than reimplementing them, which means behavior is predictable, auditable, and debuggable.

---

## Features

- **Tor routing** — run any command through Tor via `torsocks`
- **Exit verification** — confirms your traffic actually exits through Tor before proceeding
- **Tor-routed shell** — every command in the session goes through Tor
- **MAC changing** — random, vendor-valid (looks like real hardware), or custom
- **Automatic backup** — original MAC saved to `/tmp/void-anon-mac-backup.txt`
- **One-command restore** — put the original MAC back instantly
- **Auto-detect interface** — no need to specify `wlan0` or `eth0` manually
- **Graceful fallback** — works without `macchanger` (uses `ip link` directly)
- **Interactive menu** — seven-option menu for users who prefer menus over flags
- **Direct subcommands** — full CLI for scripting and automation
- **No dependencies beyond standard tools** — nothing to compile, nothing to build

---

## Requirements

| Component | Minimum |
|-----------|---------|
| OS | Linux (Debian, Ubuntu, Arch, Fedora, Kali, Parrot) |
| Shell | Bash 4.0+ |
| Root access | Required for MAC changing and starting Tor |
| Internet | Required for Tor routing |

### Required packages

```bash
sudo apt install tor torsocks macchanger curl
```

| Package | Purpose |
|---------|---------|
| `tor` | The Tor daemon |
| `torsocks` | LD_PRELOAD wrapper that forces traffic through Tor |
| `macchanger` | MAC address changing utility (optional but recommended) |
| `curl` | Used for Tor exit verification |

On non-Debian systems, substitute your package manager:

```bash
# Arch
sudo pacman -S tor torsocks macchanger curl

# Fedora
sudo dnf install tor torsocks macchanger curl
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/swagheav/VoidAnon.git
cd VoidAnon

# Make the script executable
chmod +x void-anon.sh

# Install dependencies
sudo apt install tor torsocks macchanger curl
```

No compilation. No build step. No `pip install`. Just a shell script.

---

## Usage

### Interactive menu (recommended for first use)

```bash
sudo ./void-anon.sh
```

You will see the VOID//ANON ASCII banner followed by a menu:

```
  [1] Show status
  [2] Verify Tor exit
  [3] Run a command through Tor
  [4] Start Tor-routed shell
  [5] Change MAC (random)
  [6] Change MAC (vendor-valid)
  [7] Restore original MAC
  [0] Exit
```

### Direct commands

```bash
# Show current state
./void-anon.sh status

# Verify Tor is working
./void-anon.sh verify

# Run any command through Tor
./void-anon.sh tor curl https://check.torproject.org
./void-anon.sh tor firefox
./void-anon.sh tor whois example.com

# Full Tor-routed shell
sudo ./void-anon.sh shell

# Change MAC address
sudo ./void-anon.sh mac
sudo ./void-anon.sh mac wlan0
sudo ./void-anon.sh mac wlan0 vendor
sudo ./void-anon.sh mac eth0 custom 02:11:22:33:44:55

# Restore original MAC
sudo ./void-anon.sh restore
```

---

## Commands Reference

| Command | Purpose | Root required |
|---------|---------|---------------|
| `void-anon.sh` | Interactive menu | No (asks when needed) |
| `void-anon.sh status` | Show Tor, MAC, and interface state | No |
| `void-anon.sh verify` | Confirm Tor exit IP | No |
| `void-anon.sh tor <cmd>` | Run any command through Tor | No |
| `void-anon.sh shell` | Start Tor-routed interactive shell | No |
| `void-anon.sh mac` | Change MAC (auto-detect interface) | Yes |
| `void-anon.sh mac <iface>` | Change MAC on specific interface | Yes |
| `void-anon.sh mac <iface> random` | Random MAC | Yes |
| `void-anon.sh mac <iface> vendor` | Vendor-valid MAC | Yes |
| `void-anon.sh mac <iface> custom <MAC>` | Specific MAC | Yes |
| `void-anon.sh restore [iface]` | Restore original MAC | Yes |
| `void-anon.sh help` | Show usage | No |

---

## How It Works

### Tor routing

The script uses `torsocks` — a documented `LD_PRELOAD` wrapper that intercepts network calls and routes them through the local Tor SOCKS proxy. This is the same mechanism used by the Tor Project itself.

Flow:

1. Verify Tor daemon is running (start it if not, with sudo)
2. Confirm exit IP via `check.torproject.org/api/ip` (through Tor, not directly)
3. Execute the user's command wrapped in `torsocks`

### MAC address changing

For each change:

1. Detect the active interface (via `ip route get 1.1.1.1`)
2. Read the current MAC
3. Back it up to `/tmp/void-anon-mac-backup.txt`
4. Bring interface down
5. Apply the new MAC (via `macchanger` or `ip link` directly)
6. Bring interface up
7. Read the MAC back and verify it changed

If the MAC does not change (some drivers block it), the script reports the failure honestly instead of pretending success.

---

## What This Tool Does Not Do

The script is honest about its limits. It does **not**:

- **Bypass Whonix or Qubes** — those are entire operating systems, not routing layers. No script can "pass through" them.
- **Hide you from your ISP** — your ISP still sees you connecting to Tor. What they cannot see is what's inside the Tor tunnel.
- **Protect against a targeted adversary** — Tor alone is not enough against a state-level attacker. Real protection requires behavioral discipline: no logins, no personal info, no timing patterns.
- **Make MAC changes survive every reboot** — some drivers reset the MAC on boot.
- **Bypass 802.1X port security** — enterprise networks will reject unknown MACs.
- **Make you anonymous** — anonymity is a combination of tools and behavior. This script provides two tools. Behavior is up to you.

MAC changing and Tor together hide specific identifiers from specific observers. They do not equal anonymity.

---

## Project Structure

```
VoidAnon/
├── void-anon.sh
├── README.md
└── LICENSE
```

Single-file tool. No configuration files. No database. No state beyond the MAC backup.

---

## Legal Disclaimer

> VOID//ANON is designed for authorized security research, privacy protection, and educational purposes only.
>
> - Use only on networks and devices you own or have explicit permission to test.
> - Tor is legal in most countries, but is restricted or monitored in some. Check your local laws.
> - Changing your MAC address may violate the terms of service of certain networks or captive portals.
> - The developer assumes no responsibility for misuse. You are solely accountable for your actions.

---

## Contact

| Type | Link |
|------|------|
| DM | [t.me/he6ca](https://t.me/he6ca) |
| GitHub | [@swagheav](https://github.com/swagheav) |
| Repo | [github.com/swagheav/VoidAnon](https://github.com/swagheav/VoidAnon) |

---

<p align="center">© 2026 VOID//ANON · Made by heavén · All Rights Reserved</p>
