# Development Guide

This guide is for developers who want to contribute to or modify the extension.

## Architecture

This project has two components:

1. **Chrome Extension** — provides the context menu UI in Chrome and sends messages via Native Messaging
2. **Native Messaging Host** — a Bun-compiled standalone executable (`host-binary`) that receives a URL from the extension and opens it with the macOS `open` command

The `install.sh` / `uninstall.sh` scripts register the host binary with Chrome by writing a JSON manifest to `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/`.

## Project Structure

```
├── chrome-extension/
│   ├── manifest.json       # Chrome extension manifest (V3)
│   ├── background.js       # Service worker — context menu & native messaging
│   ├── icon48.png
│   └── icon128.png
│
├── native-host/
│   ├── host.js             # Native messaging host source code
│   ├── host-binary         # Compiled Bun executable (generated — not in git)
│   └── README.md
│
├── install.sh              # One-step installer for end users
├── uninstall.sh            # One-step uninstaller for end users
├── install-dev.sh          # Developer installer (takes Extension ID as argument)
├── build-release.sh        # Builds host-binary and creates the release ZIP
└── README.md               # User documentation
```

## Development Setup

### Prerequisites

- macOS 10.15 or later
- Bun: `curl -fsSL https://bun.sh/install | bash`
- Chrome browser

> Xcode Command Line Tools are **not** required for development anymore (Swift is gone).

### Step 1: Build the Native Host

```bash
cd native-host
bun build --compile --minify --sourcemap ./host.js --outfile host-binary
cd ..
```

This creates a standalone ~60 MB executable with zero runtime dependencies.

### Step 2: Load the Chrome Extension

1. Open Chrome and go to `chrome://extensions/`
2. Enable **Developer mode** (toggle in top-right corner)
3. Click **Load unpacked** and select the `chrome-extension/` folder
4. **Copy the Extension ID** (32-character string shown under the extension name)

### Step 3: Install the Native Host for Development

Use `install-dev.sh`, which accepts the extension ID as an argument — no Chrome scanning needed:

```bash
./install-dev.sh YOUR_EXTENSION_ID
```

The script:
- Copies `native-host/host-binary` to `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/`
- Writes the JSON manifest with your extension ID in `allowed_origins`
- Sets correct permissions

**To uninstall:**
```bash
rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/open-in-default-browser-host
rm ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json
```

### Step 4: Test

1. Open any webpage with links in Chrome
2. Right-click a link
3. Select **"Open in default browser"**
4. The link should open in your system's default browser

---

## Making Changes

### Chrome Extension

1. Edit files in `chrome-extension/`
2. Go to `chrome://extensions/` and click the refresh icon on the extension
3. Test immediately — no reinstall needed

### Native Host

1. Edit `native-host/host.js`
2. Rebuild:
   ```bash
   cd native-host
   bun build --compile --minify --sourcemap ./host.js --outfile host-binary
   cd ..
   ```
3. Reinstall:
   ```bash
   ./install-dev.sh YOUR_EXTENSION_ID
   ```

---

## Testing

### Full Flow Test

```bash
# 1. Build the native host
cd native-host && bun build --compile --minify ./host.js --outfile host-binary && cd ..

# 2. Install (with your Extension ID from chrome://extensions/)
./install-dev.sh YOUR_EXTENSION_ID

# 3. Right-click a link in Chrome and test!
```

### Test the Native Host Directly

```bash
# Send a test message in Chrome's native messaging wire format
node -e "
const msg = JSON.stringify({url:'https://example.com'});
const buf = Buffer.from(msg);
const hdr = Buffer.alloc(4);
hdr.writeUInt32LE(buf.length, 0);
process.stdout.write(hdr);
process.stdout.write(buf);
" | ./native-host/host-binary
```

Should return `{"success":true}` and open example.com in your default browser.

### Quick Reinstall

```bash
# Wipe and reinstall
rm -f ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/open-in-default-browser-host
rm -f ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json
./install-dev.sh YOUR_EXTENSION_ID
```

---

## Troubleshooting

### "bun: command not found"

```bash
curl -fsSL https://bun.sh/install | bash
exec /bin/zsh  # or restart terminal
```

### Extension ID must be exactly 32 characters

Make sure you copied the full ID from `chrome://extensions/`. It looks like `abcdefghijklmnopqrstuvwxyz123456`.

### Extension not working after reinstall

1. Check the manifest has the right extension ID:
   ```bash
   cat ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.openindefaultbrowser.host.json
   ```
2. Check `allowed_origins` matches your extension ID exactly.
3. Reload the extension at `chrome://extensions/`.
4. Inspect the service worker console for error messages.

---

## Architecture Details

### Native Messaging Protocol

Chrome's native messaging uses a simple length-prefixed format:
- 4-byte little-endian integer → length of the JSON payload
- Followed by the JSON message itself
- One message per process invocation; the host exits after responding

### Extension ID Detection in `install.sh`

For end-user installs (where the extension is already in the Chrome Web Store):

1. **Python 3 path**: Parses `Secure Preferences` and `Preferences` JSON across all Chrome profiles. Unpacked extension paths are resolved by reading `manifest.json` from disk.
2. **Bash fallback**: Uses `grep` on the same preference files — no Python required.
3. **Manual fallback**: Prompts the user to enter the ID from `chrome://extensions/`.

### Why Bun?

- Creates a true standalone executable (no Node.js/npm on the user's machine needed)
- Fast startup — important for native messaging (each link click spawns a new process)
- Single binary makes distribution simple

---

## Creating a Release

```bash
./build-release.sh
```

This builds `host-binary` with Bun and packages `install.sh`, `uninstall.sh`, `host-binary`, and `README.txt` into `OpenInDefaultBrowser-v1.1.0.zip`.

See [PACKAGING.md](PACKAGING.md) for the full release checklist.

---

## Code Style

### JavaScript
- Modern ES6+ syntax
- JSDoc comments for public functions
- Handle errors gracefully

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Test on a clean macOS install
5. Update documentation if needed
6. Submit a pull request

## Resources

- [Chrome Native Messaging](https://developer.chrome.com/docs/apps/nativeMessaging/)
- [Chrome Extension Development](https://developer.chrome.com/docs/extensions/)
- [Bun Documentation](https://bun.sh/docs)
