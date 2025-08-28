#!/usr/bin/env bash
set -euo pipefail
KWC="$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)"
QDBUS="$(command -v qdbus6 || command -v qdbus || true)"
[[ -z "${KWC}" || -z "${QDBUS}" ]] && { echo "Need kde-cli-tools + qdbus"; exit 1; }
INSTALL_BASE="/opt"; BIN_BASE="/usr/local/bin"; DESKTOP_DIR="$HOME/.local/share/applications"; KWR="$HOME/.config/kwinrulesrc"
mkdir -p "$DESKTOP_DIR"
"$KWC" --file kwinrc --group Desktops --key Number 5
"$KWC" --file kwinrc --group Desktops --key Rows 2
"$KWC" --file kwinrc --group Desktops --key Name_5 "Personal"
"$KWC" --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 5" "Meta+5,none,Switch to Desktop 5"
# YouTube Music (Flatpak wrapper)
if ! flatpak info app.ytmdesktop.ytmdesktop >/dev/null 2>&1; then
  flatpak install -y flathub app.ytmdesktop.ytmdesktop
fi
sudo tee "${BIN_BASE}/ytmusic" >/dev/null <<'SH'
#!/usr/bin/env bash
exec flatpak run app.ytmdesktop.ytmdesktop "$@"
SH
sudo chmod +x "${BIN_BASE}/ytmusic"
cat >"${DESKTOP_DIR}/ytmusic.desktop"<<'EOD'
[Desktop Entry]
Name=YouTube Music
Exec=/usr/local/bin/ytmusic
Icon=app.ytmdesktop.ytmdesktop
Type=Application
Categories=Audio;Music;Player;
StartupWMClass=ytmdesktop
Terminal=false
EOD
# Snapchat (Nativefier)
command -v nativefier >/dev/null 2>&1 || { echo "Install nativefier (npm -g nativefier)"; exit 1; }
[[ -d "$HOME/Snapchat-linux-x64" ]] || nativefier -p linux -a x64 -n "Snapchat" "https://web.snapchat.com" --class-name "snapchat" --single-instance --maximize --internal-urls ".*"
sudo rm -rf /opt/snapchat; sudo mv "$HOME/Snapchat-linux-x64" /opt/snapchat; sudo ln -sf /opt/snapchat/Snapchat /usr/local/bin/snapchat
cat > "${DESKTOP_DIR}/snapchat.desktop"<<'EOD'
[Desktop Entry]
Name=Snapchat
Exec=/usr/local/bin/snapchat
Icon=/opt/snapchat/resources/app/icon.png
Type=Application
Categories=Network;Chat;Social;
StartupWMClass=snapchat
Terminal=false
EOD
# Incognito Browser (Chromium)
command -v chromium >/dev/null 2>&1 || sudo dnf install -y chromium
sudo tee "${BIN_BASE}/incognito" >/dev/null <<'SH'
#!/usr/bin/env bash
exec chromium --incognito --class=incognito "$@"
SH
sudo chmod +x "${BIN_BASE}/incognito"
cat > "${DESKTOP_DIR}/incognito.desktop"<<'EOD'
[Desktop Entry]
Name=Incognito Browser
Exec=/usr/local/bin/incognito
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
StartupWMClass=incognito
Terminal=false
EOD
# Rules → Desktop 5
for pair in "YouTube Music|ytmdesktop" "Snapchat|snapchat" "Incognito Browser|incognito"; do
  IFS='|' read -r N C <<<"$pair"
  key="[${N// /_}]"; grep -q "^$key$" "$KWR" 2>/dev/null || cat >>"$KWR"<<EOR

$key
Description=$N → Desktop 5
wmclass=$C
wmclassmatch=1
desktoprule=2
desktop=5
EOR
done
(qdbus6 org.kde.KWin /KWin reconfigure || qdbus org.kde.KWin /KWin reconfigure) 2>/dev/null || true
echo "[✓] Personal suite deployed to Desktop 5."
