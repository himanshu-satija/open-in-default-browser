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

# Create ZIP (without including the build/ folder structure)
cd build
zip -r "../$ZIP_NAME.zip" "$APP_NAME.app" -x "*.DS_Store"
cd ..

echo ""
echo "✓ ZIP created successfully!"
echo ""
echo "ZIP location: $ZIP_NAME.zip"
echo ""
echo "Users can:"
echo "1. Download the ZIP file"
echo "2. Double-click to extract"
echo "3. Drag 'Open in Default Browser.app' to Applications"
echo "4. Right-click the app and select 'Open' to bypass Gatekeeper"
