#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
APP_NAME="CodexBar"
DEST="/Applications/${APP_NAME}.app"

if [[ -z "${DEVELOPER_DIR:-}" && -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

cd "$ROOT"

CODEXBAR_SIGNING=adhoc \
CODEXBAR_SKIP_WIDGET=1 \
  ./Scripts/package_app.sh debug

rm -rf "$DEST"
cp -R "$ROOT/${APP_NAME}.app" "$DEST"
xattr -cr "$DEST"
codesign --verify --deep --strict "$DEST"

pkill -f "${DEST}/Contents/MacOS/CodexBar" 2>/dev/null || true
open -n "$DEST"

echo "Installed and launched: $DEST"
