#!/bin/bash

set -e

echo "==========================================="
echo "Open in Default Browser - Installation"
echo "==========================================="
echo ""

APP_NAME="Open in Default Browser.app"

# Check common locations
LOCATIONS=(
  "./$APP_NAME"
  "$HOME/Downloads/$APP_NAME"
  "$HOME/Desktop/$APP_NAME"
)

FOUND=false
APP_PATH=""

for location in "${LOCATIONS[@]}"; do
  if [ -d "$location" ]; then
    APP_PATH="$location"
    FOUND=true
    break
  fi
done

if [ "$FOUND" = false ]; then
  echo "❌ Error: Could not find '$APP_NAME'"
  echo ""
  echo "Please run this script from the same folder as the app:"
  echo "  cd ~/Downloads"
  echo "  ./install-app.sh"
  echo ""
  exit 1
fi

echo "Found app at: $APP_PATH"
echo ""

# Remove quarantine attribute recursively
echo "Removing security restriction..."
xattr -cr "$APP_PATH" 2>/dev/null || true

# Move to Applications if not already there
if [[ "$APP_PATH" != "/Applications/$APP_NAME" ]]; then
  echo "Moving app to Applications..."

  # Remove existing app if present
  if [ -d "/Applications/$APP_NAME" ]; then
    rm -rf "/Applications/$APP_NAME"
  fi

  cp -R "$APP_PATH" /Applications/
  APP_PATH="/Applications/$APP_NAME"
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "Launching app..."
open "$APP_PATH"

echo ""
echo "Next steps:"
echo "1. Click 'Install Native Host' from the menu bar"
echo "2. Install the Chrome extension from the Web Store"
echo "3. Right-click any link and select 'Open in default browser'"
echo ""
