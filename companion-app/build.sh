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

# Generate app icon
echo "Generating app icon..."
ICONSET_DIR="build/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"

# Generate all required icon sizes using sips
sips -z 16 16 Sources/AppIcon.png --out "$ICONSET_DIR/icon_16x16.png" > /dev/null 2>&1
sips -z 32 32 Sources/AppIcon.png --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null 2>&1
sips -z 32 32 Sources/AppIcon.png --out "$ICONSET_DIR/icon_32x32.png" > /dev/null 2>&1
sips -z 64 64 Sources/AppIcon.png --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null 2>&1
sips -z 128 128 Sources/AppIcon.png --out "$ICONSET_DIR/icon_128x128.png" > /dev/null 2>&1
sips -z 256 256 Sources/AppIcon.png --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null 2>&1
sips -z 256 256 Sources/AppIcon.png --out "$ICONSET_DIR/icon_256x256.png" > /dev/null 2>&1
sips -z 512 512 Sources/AppIcon.png --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null 2>&1
sips -z 512 512 Sources/AppIcon.png --out "$ICONSET_DIR/icon_512x512.png" > /dev/null 2>&1
sips -z 1024 1024 Sources/AppIcon.png --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null 2>&1

# Convert iconset to icns
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"

# Clean up iconset
rm -rf "$ICONSET_DIR"

# Copy host binary to Resources
echo "Copying host binary..."
cp ../native-host/host-binary "$RESOURCES_DIR/"

# Copy tray icons and alert logo to MacOS directory (same directory as executable)
echo "Copying icons..."
cp Sources/tray-icon-22.png "$MACOS_DIR/"
cp Sources/tray-icon-44.png "$MACOS_DIR/"
cp Sources/logo-64.png "$MACOS_DIR/"

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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
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
