#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

source "$ROOT/version.env"

APP_NAME="CodexBar 中文"
APP_BUNDLE="${APP_NAME}.app"
DIST_DIR="$ROOT/dist"
ARCHES_VALUE=${ARCHES:-"arm64 x86_64"}
ARCH_LABEL=${ARCH_LABEL:-"universal"}
ZIP_NAME="CodexBar-zh-macos-${ARCH_LABEL}.zip"

if [[ -z "${DEVELOPER_DIR:-}" && -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

CODEXBAR_APP_NAME="$APP_NAME" \
CODEXBAR_BUNDLE_ID="com.steipete.codexbar.debug" \
CODEXBAR_SIGNING="${CODEXBAR_SIGNING:-adhoc}" \
CODEXBAR_SKIP_WIDGET=1 \
ARCHES="$ARCHES_VALUE" \
  "$ROOT/Scripts/package_app.sh" release

codesign --verify --deep --strict "$APP_BUNDLE"
xattr -cr "$APP_BUNDLE"

/usr/bin/ditto --norsrc -c -k --keepParent "$APP_BUNDLE" "$DIST_DIR/$ZIP_NAME"
shasum -a 256 "$DIST_DIR/$ZIP_NAME" > "$DIST_DIR/${ZIP_NAME}.sha256"

cat > "$DIST_DIR/RELEASE_NOTES.md" <<EOF
CodexBar 中文版 ${MARKETING_VERSION}

- 预构建 macOS 应用包，普通用户无需安装 Xcode。
- 安装为 /Applications/CodexBar 中文.app，不覆盖官方 /Applications/CodexBar.app。
- 使用独立调试 bundle id，并关闭官方 Sparkle 更新源，避免官方更新覆盖汉化改动。
- 当前压缩包架构：${ARCH_LABEL} (${ARCHES_VALUE})。
EOF

echo "Created $DIST_DIR/$ZIP_NAME"
echo "Checksum: $DIST_DIR/${ZIP_NAME}.sha256"
