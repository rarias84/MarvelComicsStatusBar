#!/bin/bash
set -euo pipefail

PLIST="/Library/LaunchAgents/com.rarias84.MarvelComicsStatusBar.plist"
LABEL="com.rarias84.MarvelComicsStatusBar"
ACTIVE_UID="$(stat -f %u /dev/console || echo 501)"

# Descarga el agent si estaba cargado
if [[ -f "$PLIST" ]]; then
  launchctl bootout "gui/${ACTIVE_UID}" "$PLIST" >/dev/null 2>&1 || true
fi

# Cierra la app si estuviera corriendo
APP_BIN="/Applications/MarvelComicsStatusBar.app/Contents/MacOS/MarvelComicsStatusBar"
if pgrep -f "$APP_BIN" >/dev/null 2>&1; then
  pkill -f "$APP_BIN" || true
fi

exit 0