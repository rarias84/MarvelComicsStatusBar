#!/bin/bash
set -e

APP_PATH="/Applications/MarvelComicsStatusBar.app"
PLIST_PATH="/Library/LaunchAgents/com.rarias84.MarvelComicsStatusBar.plist"

# Quitar quarantine de la app y el plist
/usr/bin/xattr -dr com.apple.quarantine "$APP_PATH"
/usr/bin/xattr -dr com.apple.quarantine "$PLIST_PATH"

# Cargar LaunchAgent para el usuario actual
UID=$(stat -f %u /dev/console)
launchctl bootout gui/$UID "$PLIST_PATH" 2>/dev/null || true
launchctl bootstrap gui/$UID "$PLIST_PATH"
launchctl enable gui/$UID/com.rarias84.MarvelComicsStatusBar
launchctl kickstart -k gui/$UID/com.rarias84.MarvelComicsStatusBar

exit 0