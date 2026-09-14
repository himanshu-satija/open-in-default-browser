# Open in Default Browser - Chrome Extension

## Project Overview

A Chrome extension that allows users to open any link on a webpage in their system's default browser (which may be different from Chrome). Uses a shell-script installer to set up the required native messaging host.

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

### 3. Shell Script Installer
- `install.sh` — end-user one-step installer; auto-detects Chrome extension ID and registers the native host
- `install-dev.sh` — developer installer; accepts an explicit extension ID argument
- `uninstall.sh` — removes the native host registration
- `build-release.sh` — builds `host-binary` and packages the release ZIP

## Technical Architecture

### Native Messaging Protocol
- Chrome sends messages to native host via stdin
- Messages are prefixed with 4-byte length (little-endian)
- Native host responds via stdout with same protocol
- Format: `{length: 4 bytes}{json message}`

### Installation Flow
1. User installs Chrome extension from Web Store
2. User downloads `OpenInDefaultBrowser-vX.X.X.zip` from GitHub Releases
3. User extracts the ZIP and runs `./install.sh` in Terminal
4. The script automatically:
   - Detects Chrome extension ID by scanning Chrome's preferences/profiles
   - Copies `host-binary` to `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/`
   - Writes the JSON manifest with the detected extension ID in `allowed_origins`
   - Sets correct file permissions

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
- Native host installer: GitHub Releases (ZIP file with `install.sh`)
- Installation: 2 simple steps, no technical knowledge required

### For Developers
- Build system: Bun (native host compilation)
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
│   ├── host-binary          # Compiled executable (generated — not in git)
│   └── README.md
│
├── install.sh                # One-step installer for end users
├── uninstall.sh              # One-step uninstaller for end users
├── install-dev.sh            # Developer installer (takes Extension ID as argument)
├── build-release.sh          # Builds host-binary and creates the release ZIP
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

### Documentation Guidelines

**IMPORTANT:** When making changes that affect how developers work with the project, always update the documentation:

1. **Update DEVELOPMENT.md** when changes affect:
   - Build process or tooling
   - Installation/setup procedures
   - Testing workflows
   - New scripts or tools added to the project
   - Architecture or component interactions

2. **Update native-host/README.md** when changes affect:
   - Native host building
   - Native messaging protocol
   - Testing the native host directly

3. **Update README.md** when changes affect:
   - User-facing installation steps
   - How to use the extension
   - System requirements

4. **Examples of changes requiring documentation updates:**
   - Adding new scripts (like `install-dev.sh`)
   - Changing build commands or flags
   - Adding new dependencies or requirements
   - Modifying the native host installation flow
   - Changes to native messaging protocol or manifest

5. **Keep documentation consistent:**
   - Use the same terminology across all docs
   - Cross-reference related sections
   - Include examples for complex procedures
   - Update troubleshooting sections with new common issues

## Release Process

See [PACKAGING.md](PACKAGING.md) for:
- Building releases
- Creating DMG
- Chrome Web Store submission
- GitHub release process
