#!/usr/bin/env bash
set -euo pipefail

REPO=${CODEXBAR_ZH_REPO:-zpmdd/CodexBar-zh}
ASSET=${CODEXBAR_ZH_ASSET:-CodexBar-zh-macos-universal.zip}
APP_NAME="CodexBar"
URL=${CODEXBAR_ZH_URL:-"https://github.com/${REPO}/releases/latest/download/${ASSET}"}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/codexbar-zh.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading ${URL}"
curl -fL --progress-bar "$URL" -o "$TMP_DIR/${ASSET}"

echo "Extracting..."
/usr/bin/ditto -x -k "$TMP_DIR/${ASSET}" "$TMP_DIR/extracted"

APP_SOURCE=$(find "$TMP_DIR/extracted" -maxdepth 3 -name "${APP_NAME}.app" -type d -print -quit)
if [[ -z "$APP_SOURCE" ]]; then
  echo "ERROR: ${APP_NAME}.app not found in release archive." >&2
  exit 1
fi

DEST_DIR=${CODEXBAR_INSTALL_DIR:-/Applications}
if [[ ! -d "$DEST_DIR" || ! -w "$DEST_DIR" ]]; then
  DEST_DIR="$HOME/Applications"
  mkdir -p "$DEST_DIR"
fi
DEST="$DEST_DIR/${APP_NAME}.app"

echo "Installing to ${DEST}"
rm -rf "$DEST"
cp -R "$APP_SOURCE" "$DEST"
xattr -cr "$DEST"

codesign --verify --deep --strict "$DEST"

pkill -f "${DEST}/Contents/MacOS/CodexBar" 2>/dev/null || true
open -n "$DEST"

echo "Installed and launched: ${DEST}"
