#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="Caffeinate Toggle"
BUNDLE_ID="com.rishit.caffeinate-toggle"
APP_DIR="$HOME/Applications/$APP_NAME.app"

echo "Building..."
swift build -c release --quiet

echo "Creating app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp .build/release/CaffeinateToggle "$APP_DIR/Contents/MacOS/CaffeinateToggle"

ICON_SRC="Sources/CaffeinateToggle/Resources/AppIcon.appiconset/icon_1024.png"
if [ -f "$ICON_SRC" ]; then
  echo "Generating app icon..."
  ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
  mkdir -p "$ICONSET_DIR"
  for SIZE in 16 32 128 256 512; do
    sips -z $SIZE $SIZE "$ICON_SRC" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}.png" >/dev/null 2>&1
    DOUBLE=$((SIZE * 2))
    sips -z $DOUBLE $DOUBLE "$ICON_SRC" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}@2x.png" >/dev/null 2>&1
  done
  iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/AppIcon.icns"
  rm -rf "$(dirname "$ICONSET_DIR")"
fi

cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CaffeinateToggle</string>
    <key>CFBundleIdentifier</key>
    <string>com.rishit.caffeinate-toggle</string>
    <key>CFBundleName</key>
    <string>Caffeinate Toggle</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

echo "Installed to $APP_DIR"
echo "Run with: open \"$APP_DIR\""
