#!/bin/bash

set -e

APP_NAME="Open in Default Browser"
APP_BUNDLE="build/$APP_NAME.app"
ZIP_NAME="OpenInDefaultBrowser-v1.0.0"

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: App bundle not found. Run ./build.sh first."
    exit 1
fi

echo "Creating ZIP archive..."

# Create temporary directory with fixed name (version-independent)
# This ensures the ZIP always extracts to "OpenInDefaultBrowser" folder
TMP_DIR="build/OpenInDefaultBrowser"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# Copy app bundle
cp -R "$APP_BUNDLE" "$TMP_DIR/"

# Copy install script to temp dir
cp ../install-app.sh "$TMP_DIR/"
chmod +x "$TMP_DIR/install-app.sh"

# Create README for users
cat > "$TMP_DIR/README.txt" << 'EOF'
Open in Default Browser - Installation Instructions
====================================================

OPTION 1: Quick Install (Recommended for macOS 13+)
----------------------------------------------------
1. Open Terminal (Applications → Utilities → Terminal)
2. Type: cd Downloads/OpenInDefaultBrowser
3. Type: ./install-app.sh
4. Press Enter

The script will install the app and launch it automatically.

OPTION 2: Manual Install (macOS 12 and earlier)
------------------------------------------------
1. Drag "Open in Default Browser.app" to Applications
2. Right-click the app and select "Open"
3. Click "Open" in the dialog

After Installation
------------------
- Click "Install Native Host" from the menu bar
- Install the Chrome extension from the Web Store
- Right-click any link to test!

Need help? https://github.com/himanshu-satija/open-in-default-browser
EOF

# Create ZIP from temp directory (include the folder itself for fixed extraction path)
# This ensures the ZIP extracts to "OpenInDefaultBrowser" folder
cd build
zip -r "../$ZIP_NAME.zip" "OpenInDefaultBrowser" -x "*.DS_Store"
cd ..

# Clean up
rm -rf "$TMP_DIR"

echo ""
echo "✓ ZIP created successfully!"
echo ""
echo "ZIP location: ./companion-app/$ZIP_NAME.zip"
echo ""
echo "Contents:"
echo "- Open in Default Browser.app"
echo "- install-app.sh (helper script for macOS 13+)"
echo "- README.txt (installation instructions)"
