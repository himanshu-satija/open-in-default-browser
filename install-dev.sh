#!/bin/bash

# Development installation script for testing locally loaded extension

echo "=== Open in Default Browser - Development Installation ==="
echo ""
echo "This script installs the native messaging host for a locally loaded Chrome extension."
echo ""

# Check if extension ID is provided
if [ -z "$1" ]; then
    echo "Usage: ./install-dev.sh <EXTENSION_ID>"
    echo ""
    echo "To get your extension ID:"
    echo "  1. Open chrome://extensions/ in Chrome"
    echo "  2. Enable 'Developer mode' (top-right toggle)"
    echo "  3. Find 'Open in Default Browser' extension"
    echo "  4. Copy the Extension ID (32 character string)"
    echo ""
    echo "Example:"
    echo "  ./install-dev.sh abcdefghijklmnopqrstuvwxyz123456"
    exit 1
fi

EXTENSION_ID="$1"
HOST_NAME="com.openindefaultbrowser.host"
NATIVE_MESSAGING_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
HOST_BINARY_SOURCE="./native-host/host-binary"
HOST_BINARY_DEST="$NATIVE_MESSAGING_DIR/open-in-default-browser-host"
MANIFEST_PATH="$NATIVE_MESSAGING_DIR/$HOST_NAME.json"

# Validate extension ID format (should be 32 characters)
if [ ${#EXTENSION_ID} -ne 32 ]; then
    echo "Error: Extension ID should be exactly 32 characters long"
    echo "Got: $EXTENSION_ID (${#EXTENSION_ID} characters)"
    exit 1
fi

echo "Extension ID: $EXTENSION_ID"
echo ""

# Check if host binary exists
if [ ! -f "$HOST_BINARY_SOURCE" ]; then
    echo "Error: Host binary not found at $HOST_BINARY_SOURCE"
    echo "Please build it first:"
    echo "  cd native-host"
    echo "  bun build --compile --minify --sourcemap ./host.js --outfile host-binary"
    exit 1
fi

echo "✓ Found host binary"

# Create native messaging directory
mkdir -p "$NATIVE_MESSAGING_DIR"
echo "✓ Created native messaging directory"

# Copy host binary
cp "$HOST_BINARY_SOURCE" "$HOST_BINARY_DEST"
chmod +x "$HOST_BINARY_DEST"
echo "✓ Copied host binary to: $HOST_BINARY_DEST"

# Create manifest
cat > "$MANIFEST_PATH" << EOF
{
  "name": "$HOST_NAME",
  "description": "Native messaging host to open URLs in default browser",
  "path": "$HOST_BINARY_DEST",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXTENSION_ID/"
  ]
}
EOF

echo "✓ Created manifest at: $MANIFEST_PATH"
echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "You can now test the extension:"
echo "  1. Open any webpage in Chrome"
echo "  2. Right-click on a link"
echo "  3. Select 'Open in default browser'"
echo ""
echo "To uninstall:"
echo "  rm '$HOST_BINARY_DEST'"
echo "  rm '$MANIFEST_PATH'"
echo ""
