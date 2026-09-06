#!/bin/bash

set -e

echo "========================================="
echo "Building Release for Open in Default Browser"
echo "========================================="
echo ""

VERSION="1.1.0"
ZIP_NAME="OpenInDefaultBrowser-v${VERSION}.zip"

# Step 1: Build native host
echo "Step 1/3: Building native host..."
cd native-host
bun build --compile --minify --sourcemap ./host.js --outfile host-binary
echo "✓ Native host built"
cd ..

# Step 2: Create release ZIP
echo ""
echo "Step 2/3: Creating release ZIP..."

# Remove any existing ZIP
rm -f "$ZIP_NAME"

# Create a temporary staging directory
TMP_DIR="release-package"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# Copy required files into the staging dir
cp native-host/host-binary "$TMP_DIR/"
cp install.sh              "$TMP_DIR/"
cp uninstall.sh            "$TMP_DIR/"
chmod +x "$TMP_DIR/install.sh" "$TMP_DIR/uninstall.sh"

# Write a plain-text README for the ZIP
cat > "$TMP_DIR/README.txt" <<'EOF'
Open in Default Browser — Installation Instructions
=====================================================

1. Open Terminal  (Applications → Utilities → Terminal)
2. Run:
      cd ~/Downloads/OpenInDefaultBrowser
      ./install.sh

The installer will auto-detect your Chrome extension ID and set
everything up automatically.

If auto-detection fails (extension not yet installed), follow the
on-screen prompt to paste your extension ID from chrome://extensions/.

To uninstall:
      ./uninstall.sh

Need help? https://github.com/himanshu-satija/open-in-default-browser
EOF

# Zip it, preserving the folder name
cd "$TMP_DIR"
zip -r "../$ZIP_NAME" . -x "*.DS_Store"
cd ..

# Clean up staging dir
rm -rf "$TMP_DIR"

echo "✓ Release ZIP created: $ZIP_NAME"

# Step 3: Create extension ZIP
echo ""
echo "Step 3/3: Creating extension ZIP..."
cd chrome-extension
zip -r ../open-in-default-browser-extension.zip * -x "*.DS_Store"
cd ..
echo "✓ Extension ZIP created: open-in-default-browser-extension.zip"

echo ""
echo "========================================="
echo "Build Complete!"
echo "========================================="
echo ""
echo "Files created:"
echo "  • Installer ZIP : $ZIP_NAME"
echo "  • Extension ZIP : open-in-default-browser-extension.zip"
echo ""
echo "Next steps:"
echo "  1. Test $ZIP_NAME by extracting and running ./install.sh"
echo "  2. Upload extension ZIP to Chrome Web Store"
echo "  3. Create GitHub release and upload $ZIP_NAME"
echo ""
