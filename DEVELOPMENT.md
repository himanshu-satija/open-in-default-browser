# Development Guide

This guide is for developers who want to contribute to or modify the extension.

## Architecture

This project consists of three components:

1. **Chrome Extension**: Provides the context menu UI in Chrome
2. **Native Messaging Host**: A Bun-compiled executable that opens URLs using macOS `open` command
3. **Companion App**: A native macOS menu bar app that manages installation

## Project Structure

```
├── chrome-extension/
│   ├── manifest.json          # Chrome extension manifest (V3)
│   ├── background.js          # Service worker with context menu & native messaging
│   ├── icon48.png            # Extension icon (48x48)
│   └── icon128.png           # Extension icon (128x128)
│
├── native-host/
│   ├── host.js               # Native messaging host source code
│   ├── host-binary           # Compiled Bun executable (generated, not in git)
│   └── README.md             # Native host documentation
│
├── companion-app/
│   ├── Sources/
│   │   ├── main.swift            # App entry point
│   │   ├── AppDelegate.swift     # Menu bar UI
│   │   ├── ChromeDetector.swift  # Auto-detects Chrome extension ID
│   │   └── InstallManager.swift  # Handles install/uninstall
│   ├── build.sh              # Builds the .app bundle
│   ├── create-dmg.sh         # Creates DMG for distribution
│   └── build/                # Build output (generated)
│
└── README.md                 # User documentation
```

## Development Setup

### Prerequisites

- macOS 10.15 or later
- Xcode Command Line Tools: `xcode-select --install`
- Bun: `curl -fsSL https://bun.sh/install | bash`
- Chrome browser

### Step 1: Build the Native Host

```bash
cd native-host
bun build --compile --minify --sourcemap ./host.js --outfile host-binary
cd ..
```

This creates a standalone 60MB executable with zero dependencies.

### Step 2: Build the Companion App

```bash
cd companion-app
./build.sh
```

This compiles the Swift code and creates `build/Open in Default Browser.app`

### Step 3: Load the Chrome Extension

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" (toggle in top-right corner)
3. Click "Load unpacked"
4. Select the `chrome-extension` folder from this project
5. **Copy the Extension ID** (32-character string shown under the extension name)

**Note:** When testing with an unpacked extension, use `install-dev.sh` (see Step 4, Option A) instead of the companion app, as the companion app can only detect extensions installed from the Chrome Web Store.

### Step 4: Install Native Host for Development

Choose one of the following options based on your testing needs:

#### Option A: Using install-dev.sh (Recommended for local testing)

This is the easiest way to test with an unpacked extension in developer mode:

1. Get your Extension ID from `chrome://extensions/` (you copied this in Step 3)
2. Run the installation script:
   ```bash
   ./install-dev.sh YOUR_EXTENSION_ID
   ```
3. The script will:
   - Validate the extension ID format
   - Copy the native host binary to the correct location
   - Create the native messaging manifest with your extension ID
   - Set proper permissions

**To uninstall:**
```bash
rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/open-in-default-browser-host
rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json
```

#### Option B: Using Companion App (For testing production flow)

If you want to test the full production installation experience:

1. **Note:** This only works with extensions installed from the Chrome Web Store, not unpacked extensions
2. Launch the app: `open "companion-app/build/Open in Default Browser.app"`
3. Click "Install" from the menu bar icon
4. The app will automatically detect your Chrome extension and set everything up

### Step 5: Test

1. Open any webpage with links in Chrome
2. Right-click on a link
3. Select "Open in default browser"
4. The link should open in your system's default browser

## Making Changes

### Modifying the Chrome Extension

1. Edit files in `chrome-extension/`
2. Go to `chrome://extensions/` and click the refresh icon on the extension
3. Test your changes

### Modifying the Native Host

1. Edit `native-host/host.js`
2. Rebuild the binary:
   ```bash
   cd native-host
   bun build --compile --minify --sourcemap ./host.js --outfile host-binary
   cd ..
   ```
3. Reinstall:
   - **If using install-dev.sh:** Run `./install-dev.sh YOUR_EXTENSION_ID`
   - **If testing companion app:** Rebuild it with `cd companion-app && ./build.sh` and reinstall using the app

### Modifying the Companion App

1. Edit Swift files in `companion-app/Sources/`
2. Rebuild:
   ```bash
   cd companion-app
   ./build.sh
   ```
3. Test: `open "build/Open in Default Browser.app"`

## Testing

### Test the Full Extension Flow

This is the recommended way to test the complete functionality:

1. **Build the native host** (if not already built):
   ```bash
   cd native-host
   bun build --compile --minify --sourcemap ./host.js --outfile host-binary
   cd ..
   ```

2. **Load extension in Chrome:**
   - Open `chrome://extensions/`
   - Enable "Developer mode"
   - Click "Load unpacked" and select `chrome-extension` folder
   - Copy the Extension ID

3. **Install native host:**
   ```bash
   ./install-dev.sh YOUR_EXTENSION_ID
   ```

4. **Test it:**
   - Open any webpage in Chrome
   - Right-click on a link
   - Select "Open in default browser"
   - Verify the URL opens in your default browser

### Test the Native Host Directly

```bash
echo '{"url":"https://example.com"}' | ~/.asdf/installs/nodejs/24.4.1/bin/node -e '
const msg = require("fs").readFileSync(0, "utf-8");
const msgBuf = Buffer.from(msg);
const header = Buffer.alloc(4);
header.writeUInt32LE(msgBuf.length, 0);
process.stdout.write(header);
process.stdout.write(msgBuf);
' | ./native-host/host-binary
```

Should return `{"success":true}` and open example.com in your default browser.

### Test Chrome Extension Detection

```bash
# Run this Swift snippet to test auto-detection
swift -e '
import Foundation

let detector = ChromeDetector()
if let id = detector.detectExtensionID() {
    print("Found extension: \(id)")
} else {
    print("Extension not found")
}
'
```

## Development Workflow

For iterative development and testing:

### Making Changes to the Extension

1. **Edit** files in `chrome-extension/` (e.g., `background.js`, `manifest.json`)
2. **Reload** the extension:
   - Go to `chrome://extensions/`
   - Click the reload icon on "Open in Default Browser"
3. **Test** immediately - no reinstallation needed

### Making Changes to the Native Host

1. **Edit** `native-host/host.js`
2. **Rebuild** the binary:
   ```bash
   cd native-host
   bun build --compile --minify --sourcemap ./host.js --outfile host-binary
   cd ..
   ```
3. **Reinstall** the host:
   ```bash
   ./install-dev.sh YOUR_EXTENSION_ID
   ```
   (This copies the new binary to the correct location)
4. **Test** your changes

### Tips for Faster Iteration

- **Keep your Extension ID handy** - save it in a file or shell variable:
  ```bash
  EXTENSION_ID="abcdefghijklmnopqrstuvwxyz123456"
  ./install-dev.sh $EXTENSION_ID
  ```

- **Restart Chrome** if the extension seems stuck or not responding to changes

- **Check Chrome's extension logs** for errors:
  - Go to `chrome://extensions/`
  - Click "Inspect views: service worker" under your extension
  - Check the console for errors

- **Test native host directly** to debug native messaging issues (see "Test the Native Host Directly" section)

### Quick Reinstall

If you need to completely reinstall:

```bash
# Uninstall
rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/open-in-default-browser-host
rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json

# Reinstall
./install-dev.sh YOUR_EXTENSION_ID
```

## Troubleshooting

### Build Errors

**"swiftc: command not found"**
- Install Xcode Command Line Tools: `xcode-select --install`

**"bun: command not found"**
- Install Bun: `curl -fsSL https://bun.sh/install | bash`
- Restart terminal or run: `exec /bin/zsh`

**"host-binary not found"**
- Build the native host first: `cd native-host && bun build --compile ./host.js --outfile host-binary`

**"Extension ID should be exactly 32 characters long"** (when running install-dev.sh)
- Make sure you copied the full Extension ID from `chrome://extensions/`
- The ID should look like: `abcdefghijklmnopqrstuvwxyz123456`
- Don't include quotes or extra spaces

### Extension Not Working

1. **Check Chrome extension console:**
   - Go to `chrome://extensions/`
   - Click "Details" on the extension
   - Click "Inspect views: service worker"
   - Look for error messages

2. **Verify native host is installed:**
   ```bash
   ls -la ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
   # Should show com.openindefaultbrowser.host.json and open-in-default-browser-host
   ```
   - If files are missing, reinstall: `./install-dev.sh YOUR_EXTENSION_ID`

3. **Check manifest file has correct extension ID:**
   ```bash
   cat ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json
   ```
   - The `allowed_origins` should match your extension ID
   - If incorrect, reinstall with the correct ID

4. **Verify companion app installed correctly** (if using companion app instead of install-dev.sh):
   - Open the app and check it says "✓ Installed"
   - If not, click "Install" again
   - If install fails, check if the Chrome extension was detected:
     - The app should show an error if extension isn't found
     - Make sure the extension is loaded and enabled in Chrome
     - Note: Companion app only works with Web Store extensions, not unpacked ones

5. **Try reinstalling:**
   - **If using install-dev.sh:**
     ```bash
     # Uninstall
     rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/open-in-default-browser-host
     rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json
     # Reinstall
     ./install-dev.sh YOUR_EXTENSION_ID
     ```
   - **If using companion app:**
     - Click "Uninstall" in the companion app
     - Quit and relaunch the companion app
     - Click "Install" again

## Architecture Details

### Native Messaging Protocol

Chrome's native messaging uses a specific protocol:
- Messages are prefixed with a 4-byte length (little-endian)
- The length indicates the size of the JSON message that follows
- The native host reads from stdin and writes to stdout
- The connection is one message per process (host exits after handling)

### Companion App Flow

1. **Auto-detection**: Scans `~/Library/Application Support/Google/Chrome/*/Extensions/`
2. **Finds extension**: Matches by name "Open in Default Browser"
3. **Copies binary**: From app bundle to permanent location
4. **Creates manifest**: With detected extension ID and binary path
5. **Installs**: Copies manifest to Chrome's NativeMessagingHosts directory

### Why Bun?

- **No dependencies**: Creates standalone executable
- **Small footprint**: Better than Node.js + node_modules
- **Fast startup**: Important for native messaging
- **Easy distribution**: Single binary file

## Creating a Release

1. **Update version numbers:**
   - `chrome-extension/manifest.json`
   - `companion-app/build.sh` (Info.plist)
   - `companion-app/create-dmg.sh` (DMG_NAME)

2. **Build everything:**
   ```bash
   # Build native host
   cd native-host
   bun build --compile --minify --sourcemap ./host.js --outfile host-binary
   cd ..

   # Build companion app
   cd companion-app
   ./build.sh
   ./create-dmg.sh
   cd ..
   ```

3. **Test the DMG:**
   - Mount the DMG
   - Install to Applications
   - Test install/uninstall
   - Test with Chrome extension

4. **Create GitHub release:**
   - Tag: `v1.0.x`
   - Upload the DMG
   - Include release notes

5. **Submit to Chrome Web Store:**
   - Package extension: `cd chrome-extension && zip -r ../extension.zip *`
   - Upload to Chrome Web Store Developer Dashboard
   - Wait for review

## Code Style

### Swift
- Follow standard Swift naming conventions
- Use clear, descriptive names
- Add comments for complex logic
- Keep functions focused and small

### JavaScript
- Use modern ES6+ syntax
- Follow standard JavaScript style
- Add JSDoc comments for public functions
- Handle errors gracefully

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Test thoroughly on a clean macOS install
5. Update documentation if needed
6. Submit a pull request

## Resources

- [Chrome Native Messaging](https://developer.chrome.com/docs/apps/nativeMessaging/)
- [Chrome Extension Development](https://developer.chrome.com/docs/extensions/)
- [Bun Documentation](https://bun.sh/docs)
- [Swift Documentation](https://www.swift.org/documentation/)
