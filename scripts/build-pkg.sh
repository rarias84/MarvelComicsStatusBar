#!/usr/bin/env bash
set -euo pipefail

# Config
APP_NAME="MarvelComicsStatusBar"
BUNDLE_ID="com.rarias84.${APP_NAME}"                  # bundle id de la app
AGENT_LABEL="${BUNDLE_ID}"                            # mismo label para el LaunchAgent
PKG_ID="${BUNDLE_ID}.pkg"                             # identifier del pkg
VERSION="${1:-1.0.0}"                                 # puedes pasar versión como arg
BUILD_DIR="$(pwd)/build"
DERIVED="${BUILD_DIR}/Derived"
PKGROOT="${BUILD_DIR}/pkgroot"
OUT_PKG="${BUILD_DIR}/${APP_NAME}-${VERSION}.pkg"

# Limpia y crea estructura
rm -rf "$BUILD_DIR"
mkdir -p "${PKGROOT}/Applications" "${PKGROOT}/Library/LaunchAgents" "${BUILD_DIR}/scripts"

echo "▶️  Compilando app (Release)…"
xcodebuild -scheme "${APP_NAME}" -configuration Release -derivedDataPath "${DERIVED}" build

APP_SRC="${DERIVED}/Build/Products/Release/${APP_NAME}.app"
if [[ ! -d "${APP_SRC}" ]]; then
  echo "❌ No se encontró la app en ${APP_SRC}"
  exit 1
fi

# Copia la app al payload
cp -R "${APP_SRC}" "${PKGROOT}/Applications/"

# Detecta el ejecutable de la app
INFO_PLIST="${PKGROOT}/Applications/${APP_NAME}.app/Contents/Info.plist"
EXEC_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${INFO_PLIST}")
if [[ -z "${EXEC_NAME}" ]]; then
  echo "❌ No se pudo leer CFBundleExecutable de ${INFO_PLIST}"
  exit 1
fi
echo "✔️  Ejecutable detectado: ${EXEC_NAME}"

# Genera el LaunchAgent plist en build con la ruta correcta
AGENT_PLIST_BUILD="${BUILD_DIR}/${AGENT_LABEL}.plist"
cat > "${AGENT_PLIST_BUILD}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>${AGENT_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Applications/${APP_NAME}.app/Contents/MacOS/${EXEC_NAME}</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key>
  <dict>
    <key>SuccessfulExit</key><false/>
  </dict>
  <key>LimitLoadToSessionType</key><string>Aqua</string>
  <key>StandardOutPath</key><string>/tmp/${APP_NAME}.out.log</string>
  <key>StandardErrorPath</key><string>/tmp/${APP_NAME}.err.log</string>
</dict>
</plist>
PLIST

# Copia el LaunchAgent al payload
cp "${AGENT_PLIST_BUILD}" "${PKGROOT}/Library/LaunchAgents/${AGENT_LABEL}.plist"

# Crea scripts/postinstall (quita quarantine y arranca agent)
cat > "${BUILD_DIR}/scripts/postinstall" <<'POST'
#!/bin/bash
set -e

APP="/Applications/MarvelComicsStatusBar.app"
PLIST="/Library/LaunchAgents/com.rarias84.MarvelComicsStatusBar.plist"

# Quitar quarantine (evita bloqueos de Gatekeeper)
xattr -dr com.apple.quarantine "$APP" || true
xattr -dr com.apple.quarantine "$PLIST" || true

# Permisos seguros
chown -R root:wheel "$PLIST" || true
chmod 644 "$PLIST" || true

# (Re)cargar para el usuario activo
USER_UID=$(stat -f %u /dev/console)
launchctl bootout gui/$USER_UID "$PLIST" 2>/dev/null || true
launchctl bootstrap gui/$USER_UID "$PLIST" || true
launchctl enable gui/$USER_UID/com.rarias84.MarvelComicsStatusBar || true
launchctl kickstart -k gui/$USER_UID/com.rarias84.MarvelComicsStatusBar || true

exit 0
POST
chmod +x "${BUILD_DIR}/scripts/postinstall"

echo "📦 Construyendo PKG…"
pkgbuild \
  --root "${PKGROOT}" \
  --identifier "${PKG_ID}" \
  --version "${VERSION}" \
  --install-location "/" \
  --scripts "${BUILD_DIR}/scripts" \
  "${OUT_PKG}"

echo "✅ PKG listo: ${OUT_PKG}"
echo "ℹ️  Instala con: sudo installer -pkg \"${OUT_PKG}\" -target /"