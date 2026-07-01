#!/bin/bash
# End-user installer for Lune (no Homebrew required).
#
#   curl -fsSL https://raw.githubusercontent.com/codiku-dev/homebrew-tap/main/install.sh | bash
#
# A script piped into bash is NOT quarantined, so it can strip the
# com.apple.quarantine flag from the app after install. That avoids the
# "Lune is damaged" Gatekeeper block without any paid Apple Developer account.
set -euo pipefail

RELEASE_REPO="codiku-dev/lune-releases"
DMG_URL="${LUNE_DMG_URL:-https://github.com/${RELEASE_REPO}/releases/latest/download/Lune.dmg}"
APP_NAME="Lune.app"
DEST="/Applications/${APP_NAME}"
MIN_MACOS=14

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "✗ Lune is macOS only." >&2
  exit 1
fi

macos_major="$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d. -f1)"
if (( macos_major < MIN_MACOS )); then
  echo "✗ Lune requires macOS ${MIN_MACOS}+ (Sonoma or later)." >&2
  exit 1
fi

if ! /usr/bin/curl --version >/dev/null 2>&1; then
  echo "✗ curl is required but was not found." >&2
  exit 1
fi

TMP="$(/usr/bin/mktemp -d)"
DMG="${TMP}/Lune.dmg"
MOUNT=""

cleanup() {
  [[ -n "${MOUNT}" ]] && /usr/sbin/hdiutil detach "${MOUNT}" -quiet >/dev/null 2>&1 || true
  /bin/rm -rf "${TMP}"
}
trap cleanup EXIT

echo "→ Downloading Lune…"
/usr/bin/curl -fSL --progress-bar "${DMG_URL}" -o "${DMG}"

echo "→ Mounting…"
MOUNT="$(/usr/sbin/hdiutil attach "${DMG}" -nobrowse -readonly | /usr/bin/grep -o '/Volumes/.*' | /usr/bin/head -1)"
if [[ -z "${MOUNT}" ]]; then
  echo "✗ Could not mount the disk image." >&2
  exit 1
fi

SRC="$(/usr/bin/find "${MOUNT}" -maxdepth 1 -name "${APP_NAME}" -print -quit)"
if [[ -z "${SRC}" ]]; then
  echo "✗ ${APP_NAME} not found inside the disk image." >&2
  exit 1
fi

echo "→ Installing to /Applications…"
/bin/rm -rf "${DEST}"
/bin/cp -R "${SRC}" "${DEST}"

echo "→ Removing quarantine flag…"
/usr/bin/xattr -dr com.apple.quarantine "${DEST}" 2>/dev/null || true

echo "✓ Lune installed. Launching…"
/usr/bin/open "${DEST}"
