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

This extension adds an **"Open in default browser"** option to the right-click context menu on all links. Simply right-click any link and select this option to open it in your system's default browser.

### ⚠️ IMPORTANT: Native Host Required

**This extension requires a free native host installer to work.** Chrome extensions cannot directly open links in other browsers due to Chrome's security model — a small background binary handles this.

**Quick Setup (2 minutes):**

1. Install this extension from the Chrome Web Store ✓
2. Download the free installer: https://github.com/himanshu-satija/open-in-default-browser/releases
3. Extract (double-click) the downloaded ZIP
4. Open **Terminal** (Applications → Utilities → Terminal)
5. Type `cd ` (with a space after), then **drag the extracted folder** onto the Terminal window — this pastes the correct path automatically
6. Press **Enter**, then type `./install.sh` and press **Enter** again
7. Done! Right-click any link to try it out.

There is no persistent app — the installer registers a tiny background binary that Chrome calls on demand.

### Features

- Simple right-click context menu integration
- Works with all types of links
- Respects your system's default browser setting
- Lightweight and privacy-focused (no data collection)
- Open source
- Shows error notifications if the native host is not installed

### Platform Support

- macOS 10.15 or later

### Privacy

This extension does not collect, store, or transmit any user data. All processing happens locally on your machine. The extension only communicates with the locally-installed native host to open URLs.

### Open Source

https://github.com/himanshu-satija/open-in-default-browser

## Category

Productivity

## Language

English

## Screenshots Needed

1. Context menu showing "Open in default browser" option on a link
2. Before/after: link opening in a different browser than Chrome

## Promotional Images Needed

- Small tile: 440×280
- Marquee: 1400×560 (recommended)

## Additional Information

### Single Purpose

This extension serves a single purpose: allowing users to open links in their system's default browser via the context menu.

### Permissions Justification

- **contextMenus**: Required to add the "Open in default browser" option to the right-click menu on links
- **nativeMessaging**: Required to communicate with the locally-installed native host binary that opens URLs in the default browser
- **notifications**: Required to show error messages if the native host is not installed or something goes wrong
