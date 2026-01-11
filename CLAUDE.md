# Open in Default Browser - Chrome Extension

## Project Overview

A Chrome extension that allows users to open any link on a webpage in their system's default browser (which may be different from Chrome). Features a user-friendly macOS companion app for easy installation.

## Use Case

The primary use case that inspired this extension:
- User has Firefox as default browser with all accounts logged in
- User needs to use a Chrome PWA for an app without a native version (e.g., Google Chat)
- Links clicked in the PWA open in Chrome instead of Firefox
- This extension allows right-clicking links to open them in the default browser (Firefox)

## Components

### 1. Chrome Extension
- Manifest V3 extension
- Adds right-click context menu item: "Open in default browser"
- Communicates with native messaging host via Chrome's Native Messaging API
- Files: `chrome-extension/manifest.json`, `background.js`

### 2. Native Messaging Host
- Bun-compiled standalone executable (~60MB)
- Zero external dependencies
- Reads URL from Chrome via stdin (native messaging protocol)
- Opens URL using macOS `open` command
- Files: `native-host/host.js` (source), `host-binary` (compiled)

### 3. Companion macOS App
- Native Swift menu bar application
- Automatically detects Chrome extension ID
- One-click install/uninstall
- Manages native messaging host installation
- Files: `companion-app/Sources/*.swift`

## Technical Architecture

### Native Messaging Protocol
- Chrome sends messages to native host via stdin
- Messages are prefixed with 4-byte length (little-endian)
- Native host responds via stdout with same protocol
- Format: `{length: 4 bytes}{json message}`

### Installation Flow
1. User installs Chrome extension from Web Store
2. User downloads and installs companion app (DMG)
3. User clicks "Install" in companion app menu bar
4. App automatically:
   - Detects Chrome extension ID by scanning extensions directory
   - Copies native host binary to permanent location
   - Creates manifest with detected extension ID
   - Installs manifest to Chrome's NativeMessagingHosts directory

### Runtime Flow
1. User right-clicks link in Chrome
2. User selects "Open in default browser"
3. Chrome extension sends URL to native host
4. Native host receives message, extracts URL
5. Native host executes `open {url}`
6. URL opens in system default browser
7. Native host returns success/error to Chrome

## Requirements

- **Platform**: macOS 10.15 or later
- **Browser**: Chrome
- **User Interface**: Right-click context menu on links
- **Link Types**: All links (all `<a>` tags)
- **Dependencies**: None (fully self-contained)

## Distribution

### For Users
- Chrome extension: Chrome Web Store
- Companion app: GitHub Releases (DMG file)
- Installation: 4 simple steps, no technical knowledge required

### For Developers
- Build system: Bun (native host) + Swift (companion app)
- Source code: Open source on GitHub
- License: MIT

## Key Features

- ✅ Zero dependencies (self-contained executable)
- ✅ Automatic Chrome extension detection
- ✅ One-click installation
- ✅ Native macOS integration
- ✅ Privacy-focused (no data collection)
- ✅ Open source

## File Structure

```
├── chrome-extension/          # Chrome extension
│   ├── manifest.json
│   ├── background.js
│   └── icon*.png
│
├── native-host/              # Native messaging host
│   ├── host.js              # Source code
│   ├── host-binary          # Compiled executable
│   └── README.md
│
├── companion-app/            # macOS companion app
│   ├── Sources/
│   │   ├── main.swift
│   │   ├── AppDelegate.swift
│   │   ├── ChromeDetector.swift
│   │   └── InstallManager.swift
│   ├── build.sh
│   ├── create-dmg.sh
│   └── build/               # Generated
│
├── README.md                 # User documentation
├── DEVELOPMENT.md            # Developer guide
├── PACKAGING.md              # Release instructions
└── STORE_LISTING.md          # Chrome Web Store listing
```

## Implementation Highlights

### Bun Compilation
- Uses `bun build --compile` to create standalone executable
- Eliminates Node.js dependency for end users
- ~60MB file includes runtime and all dependencies

### Swift Menu Bar App
- Native macOS feel, small footprint (~1-2MB)
- Auto-detection reduces user friction
- Clear status indicators (✓ Installed / ✗ Not Installed)

### Chrome Extension Detection
- Scans `~/Library/Application Support/Google/Chrome/*/Extensions/`
- Matches by extension name
- Handles multiple Chrome profiles
- Falls back to manifest permission detection

## Security Considerations

- No data collection or tracking
- All processing happens locally
- Native messaging sandboxing via Chrome
- No network requests
- Open source for transparency

## Future Enhancements

Potential improvements (not currently implemented):
- Windows support
- Linux support
- Preferences for specific browsers per domain
- Keyboard shortcut option
- Statistics/usage tracking (optional)

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for:
- Build instructions
- Testing procedures
- Architecture details
- Contributing guidelines

## Release Process

See [PACKAGING.md](PACKAGING.md) for:
- Building releases
- Creating DMG
- Chrome Web Store submission
- GitHub release process
