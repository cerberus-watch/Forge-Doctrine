#!/usr/bin/env bash
set -euo pipefail
ENSURE_DESKTOPS="true"
DESKTOPS=("Comms" "Recon" "Docs" "Monitor" "Personal")
KWC="$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)"
QDBUS="$(command -v qdbus6 || command -v qdbus || true)"
[[ -z "${KWC}" ]] && { echo "kwriteconfig not found (install kde-cli-tools)."; exit 1; }
[[ -z "${QDBUS}" ]] && { echo "qdbus not found."; exit 1; }
CFG_SHORT="$HOME/.config/kglobalshortcutsrc"; mkdir -p "$HOME/.config"
cp -f "$CFG_SHORT" "$CFG_SHORT.bak.$(date +%F-%H%M)" 2>/dev/null || true
if [[ "$ENSURE_DESKTOPS" == "true" ]]; then
  "$KWC" --file kwinrc --group Desktops --key Number 5
  "$KWC" --file kwinrc --group Desktops --key Rows 2
  for i in {1..5}; do name="${DESKTOPS[$((i-1))]}"; "$KWC" --file kwinrc --group Desktops --key "Name_${i}" "$name"; done
  "$KWC" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 5" "Meta+5,none,Switch to Desktop 5"
fi
$KWC --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Meta+1,none,Switch to Desktop 1"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Meta+2,none,Switch to Desktop 2"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 3" "Meta+3,none,Switch to Desktop 3"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 4" "Meta+4,none,Switch to Desktop 4"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 5" "Meta+5,none,Switch to Desktop 5"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Desktop 1" "Meta+Shift+1,none,Window to Desktop 1"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Desktop 2" "Meta+Shift+2,none,Window to Desktop 2"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Desktop 3" "Meta+Shift+3,none,Window to Desktop 3"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Desktop 4" "Meta+Shift+4,none,Window to Desktop 4"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Desktop 5" "Meta+Shift+5,none,Window to Desktop 5"
$KWC --file kglobalshortcutsrc --group kwin --key "Quick Tile Window to the Left"  "Meta+Left,none,Quick Tile Window to the Left"
$KWC --file kglobalshortcutsrc --group kwin --key "Quick Tile Window to the Right" "Meta+Right,none,Quick Tile Window to the Right"
$KWC --file kglobalshortcutsrc --group kwin --key "Quick Tile Window to the Top"   "Meta+Up,none,Quick Tile Window to the Top"
$KWC --file kglobalshortcutsrc --group kwin --key "Quick Tile Window to the Bottom" "Meta+Down,none,Quick Tile Window to the Bottom"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Previous Screen" "Meta+Shift+Left,none,Window to Previous Screen"
$KWC --file kglobalshortcutsrc --group kwin --key "Window to Next Screen"     "Meta+Shift+Right,none,Window to Next Screen"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch One Desktop to the Left"  "Ctrl+Alt+Left,none,Switch One Desktop to the Left"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch One Desktop to the Right" "Ctrl+Alt+Right,none,Switch One Desktop to the Right"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch One Desktop Up"           "Ctrl+Alt+Up,none,Switch One Desktop Up"
$KWC --file kglobalshortcutsrc --group kwin --key "Switch One Desktop Down"         "Ctrl+Alt+Down,none,Switch One Desktop Down"
"$QDBUS" org.kde.KWin /KWin reconfigure || true
echo "[✓] Forge Meta bindings applied."
