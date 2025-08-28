#!/usr/bin/env bash
set -euo pipefail
# Requires: npm nativefier (sudo dnf -y install npm chromium; sudo npm i -g nativefier)
APPS=(
  "ChatGPT|https://chat.openai.com|chatgpt|Recon"
  "Gemini|https://gemini.google.com|gemini|Recon"
  "SuperNinja|https://app.myninja.ai|superninja|Comms"
  "Claude|https://claude.ai|claude|Recon"
  "Venice|https://venice.ai|venice|Recon"
)
BUILD_DIR="$HOME"; INSTALL_BASE="/opt"; BIN_BASE="/usr/local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"; KWR="$HOME/.config/kwinrulesrc"
mkdir -p "$DESKTOP_DIR"
build() { local n="$1" u="$2" c="$3"; [[ -d "$BUILD_DIR/${n}-linux-x64" ]] && return; nativefier -p linux -a x64 -n "$n" "$u" --class-name "$c" --single-instance --maximize --internal-urls ".*"; }
install_one(){ local n="$1" c="$2"; local src="$BUILD_DIR/${n}-linux-x64"; local dest="$INSTALL_BASE/$c"; local bin="$BIN_BASE/$c"; sudo rm -rf "$dest"; sudo mv "$src" "$dest"; sudo ln -sf "$dest/$n" "$bin"; }
desktop_entry(){ local n="$1" c="$2"; local icon="$INSTALL_BASE/$c/resources/app/icon.png"; [[ -f "$icon" ]] || icon="applications-internet"; mkdir -p "$DESKTOP_DIR"; cat >"$DESKTOP_DIR/$c.desktop"<<EOD
[Desktop Entry]
Name=$n
Exec=/usr/local/bin/$c
Icon=$icon
Type=Application
Categories=AI;Network;Utility;
StartupWMClass=$c
Terminal=false
EOD
}
rule(){ local n="$1" c="$2" label="$3"; local d=2; [[ "$label" == "Comms" ]] && d=1; local key="[${n// /_}]"; grep -q "^$key$" "$KWR" 2>/dev/null && return; cat >>"$KWR"<<EOD

$key
Description=$n → Desktop $d
wmclass=$c
wmclassmatch=1
desktoprule=2
desktop=$d
EOD
}
for I in "${APPS[@]}"; do IFS='|' read -r N U C T <<<"$I"; build "$N" "$U" "$C"; done
for I in "${APPS[@]}"; do IFS='|' read -r N U C T <<<"$I"; install_one "$N" "$C"; desktop_entry "$N" "$C"; rule "$N" "$C" "$T"; done
(qdbus6 org.kde.KWin /KWin reconfigure || qdbus org.kde.KWin /KWin reconfigure) 2>/dev/null || true
echo "[✓] AI apps deployed. SuperNinja→Comms(1); others→Recon(2)."
