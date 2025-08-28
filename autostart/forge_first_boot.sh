#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/Forge-Doctrine"
"$ROOT/bin/forge_meta_bindings.sh"
# Optional: deploy AI apps & personal suite automatically.
# Uncomment next two lines if you want zero-click provisioning:
# "$ROOT/bin/deploy_ai_apps.sh"
# "$ROOT/bin/deploy_personal_suite.sh"
# Disable this autorun
rm -f "$HOME/.config/autostart/forge_first_boot.desktop" || true
echo "[✓] Forge first-boot tasks complete."
