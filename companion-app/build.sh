#!/bin/bash

set -e

echo "Building Open in Default Browser.app..."

# Configuration
APP_NAME="Open in Default Browser"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean previous build
rm -rf "$BUILD_DIR"

# Create app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift sources
echo "Compiling Swift sources..."
# Detect architecture automatically
ARCH=$(uname -m)
SDK_PATH=$(xcrun --show-sdk-path)
swiftc -O \
    -swift-version 5 \
    -target ${ARCH}-apple-macos10.15 \
    -sdk "$SDK_PATH" \
    -module-name OpenInDefaultBrowser \
    Sources/*.swift \
    -o "$MACOS_DIR/$APP_NAME"

# Copy host binary to Resources
echo "Copying host binary..."
cp ../native-host/host-binary "$RESOURCES_DIR/"

# Copy tray icons to MacOS directory (same directory as executable)
echo "Copying tray icons..."
cp Sources/tray-icon-22.png "$MACOS_DIR/"
cp Sources/tray-icon-44.png "$MACOS_DIR/"

# Create Info.plist
echo "Creating Info.plist..."
cat > "$CONTENTS_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Open in Default Browser</string>
    <key>CFBundleIdentifier</key>
    <string>com.himanshu-satija.open-in-default-browser</string>
    <key>CFBundleName</key>
    <string>Open in Default Browser</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Himanshu Satija. All rights reserved.</string>
</dict>
</plist>
EOF

echo "✓ Build complete!"
echo ""
echo "App bundle created at: $APP_BUNDLE"
echo ""
echo "To test the app:"
echo "  open '$APP_BUNDLE'"
echo ""
echo "To create a DMG for distribution:"
echo "  ./create-dmg.sh"
