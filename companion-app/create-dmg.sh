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

echo "Creating DMG..."

# Create temporary DMG directory
TMP_DMG_DIR="build/dmg"
rm -rf "$TMP_DMG_DIR"
mkdir -p "$TMP_DMG_DIR"

# Copy app bundle
cp -R "$APP_BUNDLE" "$TMP_DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$TMP_DMG_DIR/Applications"

# Create README
cat > "$TMP_DMG_DIR/README.txt" << 'EOF'
Open in Default Browser - Installation

1. Drag "Open in Default Browser.app" to the Applications folder
2. Open the app from Applications
3. Click "Install" from the menu bar icon
4. Done!

For more information, visit:
https://github.com/himanshu-satija/open-in-default-browser

Requirements:
- macOS 10.15 or later
- Chrome browser with "Open in Default Browser" extension installed
EOF

# Create DMG
echo "Packaging DMG..."
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$TMP_DMG_DIR" \
    -ov -format UDZO \
    "build/$DMG_NAME.dmg"

# Clean up
rm -rf "$TMP_DMG_DIR"

echo ""
echo "✓ DMG created successfully!"
echo ""
echo "DMG location: build/$DMG_NAME.dmg"
echo ""
echo "You can now distribute this DMG file."
