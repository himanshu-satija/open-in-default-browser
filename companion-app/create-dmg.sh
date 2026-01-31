#!/bin/bash

set -e

APP_NAME="Open in Default Browser"
APP_BUNDLE="build/$APP_NAME.app"
DMG_NAME="OpenInDefaultBrowser-v1.0.0"
VOLUME_NAME="Open in Default Browser Installer"

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: App bundle not found. Run ./build.sh first."
    exit 1
fi

# Check if create-dmg is installed
if ! command -v create-dmg &> /dev/null; then
    echo "Error: create-dmg is not installed."
    echo "Please install it with: brew install create-dmg"
    exit 1
fi

echo "Creating DMG..."

# Create temporary DMG directory
TMP_DMG_DIR="build/dmg"
rm -rf "$TMP_DMG_DIR"
mkdir -p "$TMP_DMG_DIR"

# Copy app bundle
cp -R "$APP_BUNDLE" "$TMP_DMG_DIR/"

# Create DMG using create-dmg tool
echo "Packaging DMG with create-dmg..."
create-dmg \
  --volname "$VOLUME_NAME" \
  --volicon "$APP_BUNDLE/Contents/Resources/AppIcon.icns" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 175 190 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 425 190 \
  --no-internet-enable \
  "build/$DMG_NAME.dmg" \
  "$TMP_DMG_DIR" || {
    echo "Error: create-dmg failed. Cleaning up..."
    rm -rf "$TMP_DMG_DIR"
    exit 1
  }

# Clean up
rm -rf "$TMP_DMG_DIR"

echo ""
echo "✓ DMG created successfully!"
echo ""
echo "DMG location: build/$DMG_NAME.dmg"
echo ""
echo "You can now distribute this DMG file."
