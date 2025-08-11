#!/usr/bin/env bash
set -e

echo "🛑 Desinstalando MarvelComicsStatusBar…"
USER_UID=$(stat -f %u /dev/console)

# Descargar y deshabilitar
launchctl bootout gui/$USER_UID /Library/LaunchAgents/com.rarias84.MarvelComicsStatusBar.plist 2>/dev/null || true
launchctl disable gui/$USER_UID/com.rarias84.MarvelComicsStatusBar 2>/dev/null || true

# Quitar de Login Items (si quedó registrado ahí)
osascript -e 'tell application "System Events" to delete login item "MarvelComicsStatusBar"' || true

# Borrar archivos
sudo rm -f /Library/LaunchAgents/com.rarias84.MarvelComicsStatusBar.plist
sudo rm -rf /Applications/MarvelComicsStatusBar.app

echo "✅ Desinstalación completada."