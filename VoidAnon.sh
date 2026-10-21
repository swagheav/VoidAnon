#!/usr/bin/env bash
# ============================================================
#  VOID//ANON — Unified Anonymity Toolkit
#  Made by heavén  ·  t.me/he6ca
# ============================================================
#  Combines:
#    1. Tor routing (torsocks + verification)
#    2. MAC address changing (backup / restore)
#
#  Requirements:
#    sudo apt install tor torsocks macchanger curl
# ============================================================

set -euo pipefail

RED='\033[1;31m'; GRN='\033[1;32m'; YLW='\033[1;33m'; CYN='\033[1;36m'; DIM='\033[2m'; RST='\033[0m'
BACKUP_FILE="/tmp/void-anon-mac-backup.txt"

banner() {
  clear
  echo -e "${RED}"
  cat <<'ASCII'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⣀⡀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⣿⡇⠀⠀⠀⣠⣿⣿⣿⣿⡄⠀⠀⢸⣿⣿⣇⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⣇⠀⠀⠀⢀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⢠⣼⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⡿⠀⢸⣿⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⡄⠀⠸⣿⣿⣯⠀⠀⣿⣿⣿⡇⠀⢸⣿⣿⡇⠀⠀⠀⢰⣿⣿⣿⣷⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⡇⠀⢸⣿⠁⠀⠀⣿⣿⣿⣿⣿⣿⣿⣷⠀⠰⣿⣿⣷⠀⠀⣿⣿⣿⡇⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⡇⠀⢸⣿⠀⠀⢠⣿⣿⣿⠟⠻⣿⣿⣿⠀⠐⣿⣿⣿⠀⢸⣿⣿⣿⡇⠀⢸⣿⣿⡇⠀⠀⠀⣾⣿⣿⣿⣿⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣀⣀⣿⣇⣀⣹⣿⣀⠀⢸⣿⣿⡏⠀⠀⢻⣿⣿⡀⠀⣿⣿⣿⠀⢸⣿⣿⣿⣟⠀⢸⣿⣿⠁⠀⠀⠀⣿⣿⣿⣿⣿⡇⠀⠀⠀⣺⣿⣿⡿⠁⠀⠙⣿⣿⣿⡀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡃⢸⣿⣿⣷⠀⠀⠘⠛⠛⠀⠀⣿⣿⣿⠀⢸⣿⣿⣿⣯⠀⣽⣿⣿⠀⠀⠀⢰⣿⣿⡇⣿⣿⡇⠀⠀⠀⣽⣿⣿⡃⠀⠀⠀⢹⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡅⢸⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⢸⣿⣿⡇⢸⣿⡿⣿⣿⠀⣿⣿⣿⠀⠀⠀⢸⣿⣿⠃⣿⣿⣷⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠈⠉⠉⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠛⢻⣿⠛⠛⣿⡟⠛⠂⠀⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⢸⣿⣿⡇⢸⣿⡇⣿⣿⠀⣿⣿⡇⠀⠀⠀⢸⣿⣿⠀⢾⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⣿⠀⠀⣿⡇⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣧⠀⠀⢸⣿⣿⡇⣼⣿⡇⣿⣿⢀⣿⣿⡇⠀⠀⠀⣿⣿⡿⠀⢹⣿⣿⡃⠀⠀⣿⣿⣿⠀⠀⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⡟⠀⢠⣿⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⡀⠀⠀⣿⣿⡇⢿⣿⠀⣿⣿⡘⣿⣿⡇⠀⠀⠀⣿⣿⡇⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⢀⣀⣿⣇⣀⣸⣿⣄⡀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠘⣿⣿⡇⠀⠀⣿⣿⣿⠀⠀⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⣹⣿⣿⣿⣿⣿⣿⣿⡇⠀⢠⣤⣤⠀⠀⠉⣿⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⠀⢹⣿⣿⣿⣿⠇⠀⠀⢸⣿⣿⣷⣶⣶⣿⣿⣿⠀⠀⣿⣿⣿⡄⠀⠈⠉⢹⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⢼⣿⣿⣿⣿⣿⣿⣿⡇⠀⢸⣿⣿⡄⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⣿⡏⠀⢸⣿⣿⣿⣿⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⣻⣿⣿⡆⠀⠀⠀⣾⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠈⢹⣿⡏⠉⣿⡿⠉⠁⠀⢸⣿⣿⣧⣀⣀⣾⣿⣿⡇⠀⠀⢿⣿⣿⣿⡇⠀⢸⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢹⣿⣿⣿⣦⣤⣾⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⠂⠀⣿⡇⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⡇⠀⠘⣿⣿⣿⡟⠀⠀⢀⣿⣿⣿⠿⠿⠿⢿⣿⣿⡇⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⠀⠀⣿⡇⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⢸⣿⣿⣿⠇⠀⠀⣿⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⣇⠀⠀⢻⣿⣿⣿⣿⣿⣿⢿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⠀⠀⣿⡇⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⢨⣿⣿⣿⠂⠀⠀⣿⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠀⠀⠘⣿⣿⣿⠀⠀⠘⣿⣿⣿⣿⣿⡏⠘⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠸⠿⠀⠠⠿⠀⠀⠀⠀⠀⠀⠈⠻⠿⠿⠟⠁⠀⠀⠀⠀⠀⠛⠛⠛⠂⠀⠀⠛⠛⠛⠃⠀⠀⠛⠛⠛⠁⠀⠀⠀⠀⠛⠛⠛⠀⠀⠀⠈⠻⠿⠿⠋⠀⠘⠛⠃⠀⠀⠀⠀
ASCII
  echo -e "${RST}"
  echo -e "${CYN}  VOID//ANON  v1.0  ·  Tor Routing + MAC Changer${RST}"
  echo -e "${DIM}  Made by heavén  ·  t.me/he6ca${RST}"
  echo ""
}

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[!] This action requires sudo. Re-run: sudo $0 $*${RST}"
    exit 1
  fi
}

detect_iface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}'
}

current_mac() {
  ip link show "$1" 2>/dev/null | awk '/link\/ether/ {print $2; exit}'
}

# ── Tor ─────────────────────────────────────────────────────
check_tor() {
  if systemctl is-active --quiet tor 2>/dev/null || pgrep -x tor >/dev/null 2>&1; then
    echo -e "${GRN}[✓] Tor is running.${RST}"
    return 0
  fi
  echo -e "${YLW}[*] Tor is not running. Attempting to start...${RST}"
  need_root "tor"
  systemctl start tor 2>/dev/null || (tor >/dev/null 2>&1 &)
  sleep 3
  if pgrep -x tor >/dev/null 2>&1 || systemctl is-active --quiet tor 2>/dev/null; then
    echo -e "${GRN}[✓] Tor started.${RST}"
  else
    echo -e "${RED}[!] Tor failed to start. Install: sudo apt install tor${RST}"
    exit 1
  fi
}

verify_tor() {
  if ! command -v torsocks >/dev/null 2>&1; then
    echo -e "${RED}[!] torsocks missing. Install: sudo apt install torsocks${RST}"
    return 1
  fi
  echo -e "${CYN}[*] Verifying Tor exit...${RST}"
  local ip
  ip=$(torsocks curl -s --max-time 15 https://check.torproject.org/api/ip 2>/dev/null \
        | grep -o '"IP":"[^"]*"' | cut -d'"' -f4 || true)
  if [[ -n "${ip:-}" ]]; then
    echo -e "${GRN}[✓] Tor exit IP: $ip${RST}"
    return 0
  fi
  echo -e "${YLW}[!] Could not confirm Tor exit (network may block Tor).${RST}"
  return 1
}

run_in_tor() {
  [[ $# -eq 0 ]] && { echo -e "${RED}Usage: $0 tor <command>${RST}"; exit 1; }
  check_tor
  if ! command -v torsocks >/dev/null 2>&1; then
    echo -e "${RED}[!] torsocks missing. Install: sudo apt install torsocks${RST}"
    exit 1
  fi
  verify_tor || echo -e "${YLW}[!] Proceeding anyway.${RST}"
  echo -e "${CYN}[*] Running through Tor: $*${RST}\n"
  torsocks "$@"
}

tor_shell() {
  check_tor
  if ! command -v torsocks >/dev/null 2>&1; then
    echo -e "${RED}[!] torsocks missing. Install: sudo apt install torsocks${RST}"
    exit 1
  fi
  verify_tor || true
  echo -e "${GRN}[✓] Tor-routed shell. Type 'exit' to leave.${RST}"
  torsocks "${SHELL:-/bin/bash}"
}

# ── MAC ─────────────────────────────────────────────────────
backup_mac() {
  local iface="$1" mac="$2"
  if ! grep -q "^$iface " "$BACKUP_FILE" 2>/dev/null; then
    echo "$iface $mac" >> "$BACKUP_FILE"
    echo -e "${DIM}[*] Backed up $iface → $mac${RST}"
  fi
}

set_random_mac() {
  local iface="$1"
  if command -v macchanger >/dev/null 2>&1; then
    macchanger -r "$iface" >/dev/null 2>&1
  else
    local newmac
    newmac=$(printf '02:%02x:%02x:%02x:%02x:%02x' \
      $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    ip link set dev "$iface" address "$newmac"
  fi
}

set_vendor_mac() {
  local iface="$1"
  if command -v macchanger >/dev/null 2>&1; then
    macchanger -A "$iface" >/dev/null 2>&1
  else
    set_random_mac "$iface"
  fi
}

set_custom_mac() {
  local iface="$1" mac="$2"
  if ! [[ "$mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
    echo -e "${RED}[!] Invalid MAC format. Use XX:XX:XX:XX:XX:XX${RST}"
    exit 1
  fi
  ip link set dev "$iface" address "$mac"
}

change_mac() {
  need_root "$@"
  local iface="${1:-}" mode="${2:-random}" custom="${3:-}"

  if [[ -z "$iface" ]]; then
    iface=$(detect_iface)
    [[ -z "$iface" ]] && { echo -e "${RED}[!] Could not detect interface.${RST}"; exit 1; }
    echo -e "${DIM}[*] Auto-detected: $iface${RST}"
  fi

  local original
  original=$(current_mac "$iface")
  [[ -z "$original" ]] && { echo -e "${RED}[!] Interface '$iface' not found.${RST}"; exit 1; }
  backup_mac "$iface" "$original"

  echo -e "${CYN}[*] Interface: $iface${RST}"
  echo -e "${CYN}[*] Old MAC:   $original${RST}"

  ip link set "$iface" down
  case "$mode" in
    random)  set_random_mac "$iface" ;;
    vendor)  set_vendor_mac "$iface" ;;
    custom)  set_custom_mac "$iface" "$custom" ;;
    *)       echo -e "${RED}[!] Unknown mode: $mode${RST}"; ip link set "$iface" up; exit 1 ;;
  esac
  ip link set "$iface" up

  local updated
  updated=$(current_mac "$iface")
  if [[ -n "$updated" && "$updated" != "$original" ]]; then
    echo -e "${GRN}[✓] New MAC:   $updated${RST}"
    echo -e "${DIM}[i] Backup: $BACKUP_FILE${RST}"
  else
    echo -e "${RED}[!] MAC did not change (driver may not support it).${RST}"
    exit 1
  fi
}

restore_mac() {
  need_root "$@"
  local iface="${1:-}"
  [[ ! -f "$BACKUP_FILE" ]] && { echo -e "${YLW}[!] No backup file. Nothing to restore.${RST}"; exit 1; }
  [[ -z "$iface" ]] && iface=$(awk 'NR==1 {print $1}' "$BACKUP_FILE")

  local original
  original=$(awk -v i="$iface" '$1==i {print $2; exit}' "$BACKUP_FILE")
  [[ -z "$original" ]] && { echo -e "${RED}[!] No backup for $iface.${RST}"; exit 1; }

  echo -e "${CYN}[*] Restoring $iface → $original${RST}"
  ip link set "$iface" down
  ip link set dev "$iface" address "$original"
  ip link set "$iface" up

  local now
  now=$(current_mac "$iface")
  if [[ "$now" == "$original" ]]; then
    echo -e "${GRN}[✓] Restored: $now${RST}"
  else
    echo -e "${RED}[!] Restore failed. Current: $now${RST}"
  fi
}

# ── Status ──────────────────────────────────────────────────
show_status() {
  echo -e "${CYN}── STATUS ──────────────────────────────${RST}"
  if pgrep -x tor >/dev/null 2>&1 || systemctl is-active --quiet tor 2>/dev/null; then
    echo -e "Tor service:   ${GRN}running${RST}"
  else
    echo -e "Tor service:   ${RED}stopped${RST}"
  fi
  command -v torsocks   >/dev/null 2>&1 && echo -e "torsocks:      ${GRN}installed${RST}" || echo -e "torsocks:      ${RED}missing${RST}"
  command -v macchanger >/dev/null 2>&1 && echo -e "macchanger:    ${GRN}installed${RST}" || echo -e "macchanger:    ${YLW}missing (optional)${RST}"
  local iface
  iface=$(detect_iface)
  if [[ -n "${iface:-}" ]]; then
    echo -e "Interface:     $iface"
    echo -e "MAC address:   $(current_mac "$iface")"
  fi
  if [[ -f "$BACKUP_FILE" ]]; then
    echo -e "${CYN}Backups:${RST}"
    while read -r i m; do echo -e "  $i → $m"; done < "$BACKUP_FILE"
  fi
  echo -e "${CYN}────────────────────────────────────────${RST}"
}

# ── Menu ────────────────────────────────────────────────────
interactive_menu() {
  while true; do
    banner
    echo -e "${CYN}  [1]${RST} Show status"
    echo -e "${CYN}  [2]${RST} Verify Tor exit"
    echo -e "${CYN}  [3]${RST} Run a command through Tor"
    echo -e "${CYN}  [4]${RST} Start Tor-routed shell"
    echo -e "${CYN}  [5]${RST} Change MAC (random)"
    echo -e "${CYN}  [6]${RST} Change MAC (vendor-valid)"
    echo -e "${CYN}  [7]${RST} Restore original MAC"
    echo -e "${CYN}  [0]${RST} Exit"
    echo ""
    read -rp "  Select: " choice
    echo ""
    case "$choice" in
      1) show_status ;;
      2) verify_tor ;;
      3) read -rp "  Command: " cmd; run_in_tor $cmd ;;
      4) tor_shell ;;
      5) change_mac ;;
      6) change_mac "" vendor ;;
      7) restore_mac ;;
      0) exit 0 ;;
      *) echo -e "${RED}[!] Invalid choice.${RST}" ;;
    esac
    echo ""
    read -rp "  Press Enter to continue..." _
  done
}

usage() {
  banner
  cat <<EOF
${CYN}USAGE${RST}
  $0                                 Interactive menu
  $0 status                          Show current state
  $0 verify                          Verify Tor exit IP
  $0 tor <command>                   Run command through Tor
  $0 shell                           Start Tor-routed shell
  $0 mac [iface] [mode] [custom]     Change MAC
  $0 restore [iface]                 Restore original MAC

${CYN}MAC MODES${RST}
  random   Random MAC (default)
  vendor   Vendor-valid MAC (macchanger -A)
  custom   Specific MAC: $0 mac wlan0 custom 02:11:22:33:44:55

${CYN}EXAMPLES${RST}
  $0 tor curl https://check.torproject.org
  $0 tor firefox
  $0 mac
  $0 mac wlan0 vendor
  $0 mac eth0 custom 02:11:22:33:44:55
  $0 restore

${CYN}INSTALL${RST}
  sudo apt install tor torsocks macchanger curl

EOF
}

# ── Entry ───────────────────────────────────────────────────
case "${1:-}" in
  "" )                interactive_menu ;;
  status )            banner; show_status ;;
  verify )            banner; verify_tor ;;
  tor )               banner; shift; run_in_tor "$@" ;;
  shell )             banner; tor_shell ;;
  mac )               banner; shift; change_mac "${1:-}" "${2:-random}" "${3:-}" ;;
  restore )           banner; shift; restore_mac "${1:-}" ;;
  -h|--help|help )    usage ;;
  * )                 echo -e "${RED}[!] Unknown command: $1${RST}"; usage; exit 1 ;;
esac
