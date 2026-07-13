#!/bin/bash
# Install Lune: Homebrew when available, otherwise curl the release .dmg.
#
#   bash -c "$(curl -fsSL -H 'Accept: application/vnd.github.raw+json' \
#     https://api.github.com/repos/codiku-dev/homebrew-tap/contents/install.sh?ref=main)"
set -euo pipefail

RELEASE_REPO="codiku-dev/lune-releases"
TAP="codiku-dev/tap"
CASK="lune"
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

BREW="$(command -v brew || true)"
if [[ -n "${BREW}" ]]; then
  echo "→ Installing via Homebrew…"
  "${BREW}" tap "${TAP}" 2>/dev/null || true
  if "${BREW}" list --cask "${CASK}" >/dev/null 2>&1; then
    "${BREW}" upgrade --cask "${CASK}"
  else
    "${BREW}" install --cask "${CASK}"
  fi
  echo "✓ Lune installed. Launching…"
  /usr/bin/open -a Lune
  exit 0
fi

if ! /usr/bin/curl --version >/dev/null 2>&1; then
  echo "✗ curl is required (or install Homebrew from https://brew.sh)." >&2
  exit 1
fi

echo "→ Homebrew not found — downloading the latest release…"
TAG="$(
  /usr/bin/curl -fsSL "https://api.github.com/repos/${RELEASE_REPO}/releases/latest" \
    | /usr/bin/sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\([^"]*\)".*/\1/p' \
    | /usr/bin/head -n 1
)"
if [[ -z "${TAG}" ]]; then
  echo "✗ Could not resolve the latest Lune version." >&2
  exit 1
fi

DMG_URL="https://github.com/${RELEASE_REPO}/releases/download/v${TAG}/Lune-${TAG}.dmg"
TMP="$(/usr/bin/mktemp -d)"
DMG="${TMP}/Lune.dmg"
MOUNT=""

cleanup() {
  [[ -n "${MOUNT}" ]] && /usr/sbin/hdiutil detach "${MOUNT}" -quiet >/dev/null 2>&1 || true
  /bin/rm -rf "${TMP}"
}
trap cleanup EXIT

echo "→ Downloading Lune ${TAG}…"
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
