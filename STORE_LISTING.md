# Chrome Web Store Listing

## Extension Name
Open in Default Browser

## Short Description (132 characters max)
Open links in your system's default browser via right-click menu. Perfect for PWAs when you want links to open elsewhere.

## Detailed Description

Open any link in your system's default browser with a simple right-click.

### The Problem This Solves

Do you use Chrome for specific apps (like PWAs) but prefer a different browser for everything else? This extension is for you.

**Common Use Case:**
- You use Firefox (or another browser) as your default browser with all your accounts logged in
- You use a Chrome PWA for an app that doesn't have a native desktop version (like Google Chat, Slack, etc.)
- When you click links in the PWA, they open in Chrome instead of your default browser
- You want those links to open in your default browser where you're already logged in

### The Solution

This extension adds a "Open in default browser" option to the right-click context menu on all links. Simply right-click any link and select this option to open it in your system's default browser instead of Chrome.

### Features

- Simple right-click context menu integration
- Works with all types of links
- Respects your system's default browser setting
- Lightweight and privacy-focused (no data collection)
- Open source

### Important: Companion App Required

This extension requires a companion native messaging host to be installed on your system. The extension alone cannot open links in other browsers due to Chrome's security model.

**Installation Steps:**
1. Install this extension from the Chrome Web Store
2. Download the companion app from: https://github.com/himanshu-satija/open-in-default-browser/releases
3. Open the DMG file and drag the app to Applications
4. Launch the app and click "Install" - it's that simple!

### Platform Support

- macOS only (currently)

### Privacy

This extension does not collect, store, or transmit any user data. All processing happens locally on your machine. The extension only communicates with the locally-installed companion app to open URLs.

### Open Source

This extension is open source and available on GitHub:
https://github.com/himanshu-satija/open-in-default-browser

Found a bug or want to contribute? Visit the GitHub repository!

## Category
Productivity

## Language
English

## Screenshots Needed
1. Context menu showing "Open in default browser" option
2. Extension icon and popup (if applicable)
3. Before/after comparison showing link opening in different browser

## Promotional Images Needed
- Small tile: 440x280
- Marquee: 1400x560 (optional but recommended)

## Additional Information

### Single Purpose
This extension serves a single purpose: allowing users to open links in their system's default browser via context menu.

### Permissions Justification
- **contextMenus**: Required to add the "Open in default browser" option to the right-click menu
- **nativeMessaging**: Required to communicate with the companion app that opens URLs in the default browser
- **notifications**: Required to show error messages if the companion app is not installed or if something goes wrong
