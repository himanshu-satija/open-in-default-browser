#!/bin/bash

set -e

echo "========================================="
echo "Building Release for Open in Default Browser"
echo "========================================="
echo ""

VERSION="1.0.0"

# Step 1: Build native host
echo "Step 1/4: Building native host..."
cd native-host
if [ ! -f "host-binary" ]; then
    bun build --compile --minify --sourcemap ./host.js --outfile host-binary
    echo "✓ Native host built"
else
    echo "✓ Native host already exists"
fi
cd ..

# Step 2: Build companion app
echo ""
echo "Step 2/4: Building companion app..."
cd companion-app
./build.sh
echo "✓ Companion app built"
cd ..

# Step 3: Create ZIP
echo ""
echo "Step 3/4: Creating ZIP..."
cd companion-app
./create-zip.sh
echo "✓ ZIP created"
cd ..

# Step 4: Create extension ZIP
echo ""
echo "Step 4/4: Creating extension ZIP..."
cd chrome-extension
zip -r ../open-in-default-browser-extension.zip * -x "*.DS_Store"
cd ..
echo "✓ Extension ZIP created"

echo ""
echo "========================================="
echo "Build Complete!"
echo "========================================="
echo ""
echo "Files created:"
echo "  • Extension ZIP: open-in-default-browser-extension.zip"
echo "  • Companion ZIP: OpenInDefaultBrowser-v${VERSION}.zip"
echo ""
echo "Next steps:"
echo "  1. Test the extension ZIP by loading it unpacked in Chrome"
echo "  2. Test the companion ZIP by extracting and installing the app"
echo "  3. Upload extension ZIP to Chrome Web Store"
echo "  4. Create GitHub release and upload the companion ZIP"
echo ""
