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

### Step 2: Install the Companion App

**Important:** This extension requires a companion app to work. This is due to Chrome's security model - extensions cannot directly open links in other browsers.

1. **Download `OpenInDefaultBrowser.dmg`** from the [Releases page](https://github.com/himanshu-satija/open-in-default-browser/releases)
2. **Open the DMG file**
3. **Drag "Open in Default Browser.app"** to your Applications folder
4. **Launch the app** from Applications
5. **A welcome message will appear** - click "Show Menu" to continue
6. **Click "Install Native Host"** from the menu
7. Done! The app will automatically detect your Chrome extension and configure everything.

## Usage

1. Right-click on any link in Chrome
2. Select "Open in default browser" from the context menu
3. The link opens in your system's default browser

## Requirements

- macOS 10.15 or later
- Chrome browser
- No other dependencies! (The app is completely self-contained)

## Troubleshooting

### The context menu option doesn't appear
- Make sure the extension is installed and enabled in `chrome://extensions/`

### Clicking the option does nothing
- Make sure you've installed the companion app and clicked "Install Native Host" in the menu bar
- Open the companion app from Applications and check if it says "✓ Installed"
- If not installed, click "Install Native Host" from the menu bar icon
- Check the Chrome extension console for errors:
  1. Go to `chrome://extensions/`
  2. Click "Details" on this extension
  3. Click "Inspect views: service worker"
  4. Look for error messages

### The companion app says it can't find the Chrome extension
- Make sure the Chrome extension is installed from the Chrome Web Store
- The extension must be enabled in `chrome://extensions/`
- Try restarting Chrome and then opening the companion app again

### Still having issues?
[Open an issue on GitHub](https://github.com/himanshu-satija/open-in-default-browser/issues)

## Uninstallation

1. **Uninstall from the companion app:**
   - Open the app from menu bar
   - Click "Uninstall Native Host"
   - Quit the app
   - Delete the app from Applications

2. **Remove the Chrome extension:**
   - Go to `chrome://extensions/`
   - Click "Remove" on the extension

## Privacy

This extension does **not** collect, store, or transmit any user data. All processing happens locally on your machine. The extension only communicates with the locally-installed companion app to open URLs.

## Contributing

This project is open source! Contributions are welcome.

- 🐛 [Report bugs](https://github.com/himanshu-satija/open-in-default-browser/issues)
- 💡 [Suggest features](https://github.com/himanshu-satija/open-in-default-browser/issues)
- 🔧 [Submit pull requests](https://github.com/himanshu-satija/open-in-default-browser/pulls)

See [DEVELOPMENT.md](DEVELOPMENT.md) for development setup instructions.

## License

MIT License - see [LICENSE](LICENSE) file for details

---

**Note:** Currently supports macOS only. Windows and Linux support may be added in the future.
