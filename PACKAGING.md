# Packaging Guide

This guide explains how to build and publish the extension and the native host installer.

## Part 1: Package Chrome Extension for Web Store

### Prerequisites

1. A Google account
2. Developer registration on Chrome Web Store ($5 one-time fee)
3. Extension files ready in `chrome-extension/`

### Steps

1. **Verify extension files:**
   ```bash
   ls chrome-extension/
   # Should show: manifest.json  background.js  icon48.png  icon128.png
   ```

2. **Create a ZIP file:**
   ```bash
   cd chrome-extension
   zip -r ../open-in-default-browser-extension.zip * -x "*.DS_Store"
   cd ..
   ```

3. **Go to the Chrome Web Store Developer Dashboard:**
   - Visit: https://chrome.google.com/webstore/devconsole
   - Sign in and register as a developer if needed

4. **Create a new item:**
   - Click **New Item**
   - Upload `open-in-default-browser-extension.zip`
   - Fill in details from `STORE_LISTING.md`

5. **Required information:**
   - **Store listing:** copy from `STORE_LISTING.md`
   - **Privacy policy URL:** use the raw GitHub URL of `PRIVACY.md`
     - Example: `https://raw.githubusercontent.com/himanshu-satija/open-in-default-browser/main/PRIVACY.md`
   - **Category:** Productivity
   - **Language:** English

6. **Upload promotional images:**
   - Small tile: 440×280 (required)
   - Marquee: 1400×560 (recommended)
   - Screenshots of the extension in action

7. **Submit for review** — usually approved within 1–3 business days

---

## Part 2: Create GitHub Release for Native Host Installer

### Prerequisites

1. A GitHub account with access to this repository
2. Bun installed: `curl -fsSL https://bun.sh/install | bash`

### Steps

1. **Build everything:**
   ```bash
   ./build-release.sh
   ```

   This will:
   - Compile `native-host/host.js` into a standalone `host-binary` using Bun
   - Package `install.sh`, `uninstall.sh`, `host-binary`, and `README.txt` into `OpenInDefaultBrowser-v1.1.0.zip`

2. **Test the ZIP locally:**
   ```bash
   # Extract to a temp folder
   mkdir -p /tmp/test-release
   unzip OpenInDefaultBrowser-v1.1.0.zip -d /tmp/test-release
   cd /tmp/test-release
   ./install.sh
   # Verify: right-click a link in Chrome and test
   ./uninstall.sh
   ```

3. **Create a GitHub release:**
   - Go to your repository on GitHub
   - Click **Releases** in the right sidebar
   - Click **Create a new release**

4. **Release information:**
   - **Tag version:** `v1.1.0`
   - **Release title:** `Open in Default Browser v1.1.0`
   - **Description:**
     ```markdown
     ## Open in Default Browser v1.1.0

     Enables the "Open in Default Browser" Chrome extension to open links
     in your system's default browser.

     ### Installation (2 steps)

     1. Download `OpenInDefaultBrowser-v1.1.0.zip` below
     2. Extract it, then open Terminal and run:
        ```bash
        cd ~/Downloads/OpenInDefaultBrowser-v1.1.0
        ./install.sh
        ```

     The script auto-detects your Chrome extension ID and sets everything up.
     If the extension isn't installed yet, you can paste the ID manually when prompted.

     ### Uninstall

     ```bash
     cd ~/Downloads/OpenInDefaultBrowser-v1.1.0
     ./uninstall.sh
     ```

     ### Requirements

     - macOS 10.15 (Catalina) or later
     - Chrome browser with the "Open in Default Browser" extension installed

     ### What's included in the ZIP

     | File | Purpose |
     |------|---------|
     | `install.sh` | Installs the native messaging host |
     | `uninstall.sh` | Removes the native messaging host |
     | `host-binary` | Standalone executable that opens URLs |
     | `README.txt` | Quick-start instructions |

     Full documentation: [README](https://github.com/himanshu-satija/open-in-default-browser/blob/main/README.md)
     ```

5. **Upload the ZIP:**
   - Drag and drop `OpenInDefaultBrowser-v1.1.0.zip` to the release assets

6. **Publish the release**

---

## Part 3: Update Extension Listing

After publishing to GitHub:

1. **Update `README.md`** — add the Chrome Web Store link once approved
2. **Update Chrome Web Store listing** — add the link to the GitHub releases page
3. Verify all GitHub URLs are correct

---

## Version Updates

When releasing a new version:

1. **Update `chrome-extension/manifest.json`:**
   ```json
   { "version": "1.0.1" }
   ```

2. **Update `build-release.sh`:**
   ```bash
   VERSION="1.0.1"
   ```

3. **Build and publish** following Part 2 above.

---

## Pre-publication Checklist

- [ ] `manifest.json` has the correct version
- [ ] `PRIVACY.md` is complete
- [ ] `README.md` has no placeholder text (e.g. Chrome Web Store link)
- [ ] All GitHub usernames/URLs are correct
- [ ] Extension tested end-to-end (install → right-click → link opens)
- [ ] `install.sh` tested on a clean extract (fresh directory, no prior install)
- [ ] `uninstall.sh` tested
- [ ] Screenshots prepared for Chrome Web Store
- [ ] Promotional images created

---

## Post-Publication

After Chrome Web Store approval:

1. Update `README.md` with the Chrome Web Store link
2. Share on relevant communities (optional)
3. Monitor GitHub Issues for user feedback

---

## Resources

- [Chrome Web Store Developer Documentation](https://developer.chrome.com/docs/webstore/)
- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Chrome Native Messaging](https://developer.chrome.com/docs/apps/nativeMessaging/)
