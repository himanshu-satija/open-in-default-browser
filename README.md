# Open in Default Browser

<p align="center">
  <strong>Open any link in your system's default browser with a simple right-click</strong>
</p>

## The Problem

Do you use Chrome for specific apps (like PWAs) but prefer a different browser for everything else?

**Common scenario:**

- You use Firefox (or another browser) as your default browser with all your accounts logged in
- You use a Chrome PWA for an app that doesn't have a native desktop version (like Google Chat, Slack, WhatsApp, etc.)
- When you click links in the PWA, they open in Chrome instead of your default browser
- You want those links to open in your default browser where you're already logged in

**This extension solves that problem.**

## Features

- ✅ Simple right-click context menu integration
- ✅ Works with all types of links
- ✅ Respects your system's default browser setting
- ✅ Lightweight and privacy-focused (no data collection)
- ✅ Open source

## Installation

### Step 1: Install the Chrome Extension

Install from the Chrome Web Store: [Link will be added after publishing]

### Step 2: Install the Native Host

**Important:** This extension requires a small native helper to work. Chrome extensions cannot directly open links in other browsers, so a tiny background binary handles this for you — there is no persistent app.

1. **Download `OpenInDefaultBrowser-<latest>.zip`** from the [Releases page](https://github.com/himanshu-satija/open-in-default-browser/releases)
2. **Double-click to extract** the ZIP file
3. **Open Terminal** (Applications → Utilities → Terminal)
4. Type `cd ` (with a space after), then **drag the extracted folder** onto the Terminal window — this pastes the correct path automatically
5. Press **Enter**, then type `./install.sh` and press **Enter** again
6. Done! The script detects your Chrome extension automatically and sets everything up.

**That's it** — no app to launch, nothing running in the background.

## Usage

1. Right-click on any link in Chrome
2. Select **"Open in default browser"** from the context menu
3. The link opens in your system's default browser

## Requirements

- macOS 10.15 (Catalina) or later
- Chrome browser
- No other dependencies

## Troubleshooting

### The context menu option doesn't appear

- Make sure the extension is installed and enabled in `chrome://extensions/`

### Clicking the option does nothing

- Make sure you ran `./install.sh` from the release ZIP
- Verify the native host is installed:
  ```bash
  ls ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
  # Should show com.openindefaultbrowser.host.json and open-in-default-browser-host
  ```
- If files are missing, re-run `./install.sh`
- Check the Chrome extension console for errors:
  1. Go to `chrome://extensions/`
  2. Click **Details** on this extension
  3. Click **Inspect views: service worker**
  4. Look for error messages

### The installer says it can't find the Chrome extension

The installer tries to auto-detect your extension ID. If it can't:

1. Open `chrome://extensions/` in Chrome
2. Enable **Developer mode** (toggle in the top-right corner)
3. Find **Open in Default Browser** and copy its 32-character ID
4. Re-run the installer and paste the ID when prompted:
   ```bash
   ./install.sh YOUR_EXTENSION_ID
   ```

### Still having issues?

[Open an issue on GitHub](https://github.com/himanshu-satija/open-in-default-browser/issues)

## Uninstallation

```bash
cd ~/Downloads/OpenInDefaultBrowser
./uninstall.sh
```

Then remove the Chrome extension at `chrome://extensions/`.

## Privacy

This extension does **not** collect, store, or transmit any user data. All processing happens locally on your machine. The extension only communicates with the locally-installed native host binary to open URLs.

## Contributing

This project is open source! Contributions are welcome.

- 🐛 [Report bugs](https://github.com/himanshu-satija/open-in-default-browser/issues)
- 💡 [Suggest features](https://github.com/himanshu-satija/open-in-default-browser/issues)
- 🔧 [Submit pull requests](https://github.com/himanshu-satija/open-in-default-browser/pulls)

See [DEVELOPMENT.md](DEVELOPMENT.md) for development setup instructions.

## License

MIT License — see [LICENSE](LICENSE) file for details

---

**Note:** Currently supports macOS only. Windows and Linux support may be added in the future.
