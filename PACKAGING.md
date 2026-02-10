# Packaging Guide

This guide explains how to package and publish the extension and companion app.

## Part 1: Package Chrome Extension for Web Store

### Prerequisites

1. A Google account
2. Developer registration on Chrome Web Store ($5 one-time fee)
3. The extension files ready in the `chrome-extension/` directory

### Steps

1. **Verify extension files:**
   ```bash
   cd chrome-extension
   ls -la
   ```
   You should see:
   - `manifest.json`
   - `background.js`
   - `icon48.png`
   - `icon128.png`

2. **Create a ZIP file:**
   ```bash
   cd chrome-extension
   zip -r ../open-in-default-browser-extension.zip *
   cd ..
   ```

3. **Go to Chrome Web Store Developer Dashboard:**
   - Visit: https://chrome.google.com/webstore/devconsole
   - Sign in with your Google account
   - Register as a developer if you haven't already

4. **Create a new item:**
   - Click "New Item"
   - Upload `open-in-default-browser-extension.zip`
   - Fill in the required information using `STORE_LISTING.md` as reference

5. **Required information:**
   - **Store listing:** Copy from `STORE_LISTING.md`
   - **Privacy policy URL:** After publishing to GitHub, use the raw URL of `PRIVACY.md`
     - Example: `https://raw.githubusercontent.com/himanshu-satija/open-in-default-browser/main/PRIVACY.md`
   - **Category:** Productivity
   - **Language:** English

6. **Upload promotional images:**
   - Small tile: 440x280 (required)
   - Marquee: 1400x560 (recommended)
   - Screenshots showing the extension in action

7. **Submit for review:**
   - Review all information
   - Click "Submit for review"
   - Wait for Chrome Web Store team approval (usually 1-3 business days)

## Part 2: Create GitHub Release for Companion App

### Prerequisites

1. A GitHub account
2. Repository created at github.com/himanshu-satija/open-in-default-browser
3. All code pushed to the repository
4. Bun installed on your machine

### Steps

1. **Build the companion app:**

   ```bash
   # Compile host.js to binary
   cd native-host
   bun build --compile --minify --sourcemap ./host.js --outfile host-binary
   cd ..

   # Build the macOS app
   cd companion-app
   ./build.sh

   # Create ZIP for distribution
   ./create-zip.sh
   ```

   This will create `OpenInDefaultBrowser-v1.0.0.zip` in the project root.

2. **Test the ZIP:**

   - Extract the ZIP file
   - Drag the app to Applications
   - Right-click the app and select "Open" (to bypass Gatekeeper on first launch)
   - Launch the app
   - Test Install/Uninstall functionality

3. **Create a GitHub release:**
   - Go to your repository on GitHub
   - Click "Releases" in the right sidebar
   - Click "Create a new release"

4. **Release information:**
   - **Tag version:** `v1.0.0`
   - **Release title:** `Open in Default Browser v1.0.0`
   - **Description:**
     ```markdown
     ## Open in Default Browser - Companion App

     A simple Mac menu bar app that enables the "Open in Default Browser" Chrome extension.

     ### Installation

     1. Download `OpenInDefaultBrowser-v1.0.0.zip`
     2. Double-click to extract the ZIP file
     3. Drag "Open in Default Browser.app" to Applications
     4. Right-click the app and select "Open" (first launch only - to bypass Gatekeeper)
     5. Click "Install Native Host" from the menu bar icon
     6. Done!

     ### Features

     - ✅ Zero dependencies (completely self-contained)
     - ✅ Automatic Chrome extension detection
     - ✅ One-click install/uninstall
     - ✅ Native macOS menu bar app

     ### Requirements

     - macOS 10.15 or later
     - Chrome browser with "Open in Default Browser" extension installed from Chrome Web Store

     ### Note

     The app is not signed with an Apple Developer certificate. On first launch, you'll need to right-click and select "Open" to bypass Gatekeeper. This is normal for unsigned apps and is safe to do.

     For full documentation, see the [README](https://github.com/himanshu-satija/open-in-default-browser/blob/main/README.md).
     ```

5. **Upload the ZIP:**
   - Drag and drop `OpenInDefaultBrowser-v1.0.0.zip` to the release assets section

6. **Publish the release:**
   - Click "Publish release"

## Part 3: Update Extension Listing

After publishing to GitHub:

1. **Get the release URL:**
   - Copy the URL to your release page
   - Example: `https://github.com/himanshu-satija/open-in-default-browser/releases`

2. **Update Chrome Web Store listing:**
   - Add link to GitHub releases in the detailed description
   - Update privacy policy URL to point to your GitHub

3. **Update README.md:**
   - Add the Chrome Web Store link once approved
   - Verify all GitHub URLs are correct

## Version Updates

When releasing a new version:

1. **Update version in `manifest.json`:**
   ```json
   {
     "version": "1.0.1"
   }
   ```

2. **Create new extension ZIP:**
   ```bash
   cd chrome-extension
   zip -r ../open-in-default-browser-extension-v1.0.1.zip *
   ```

3. **Upload to Chrome Web Store:**
   - Go to Developer Dashboard
   - Click on your extension
   - Click "Package" → "Upload new package"
   - Upload the new ZIP

4. **Create new GitHub release** if companion app changed:
   - Build new ZIP with updated version number
   - Follow Part 2 steps with new version number

## Checklist

Before publishing:

- [ ] All icons are present and correct size
- [ ] manifest.json has correct version
- [ ] PRIVACY.md is complete
- [ ] README.md has no placeholder text
- [ ] All GitHub usernames are updated
- [ ] Extension tested and working
- [ ] Companion app tested on fresh macOS install
- [ ] install.sh is executable (`chmod +x`)
- [ ] uninstall.sh is executable (`chmod +x`)
- [ ] Screenshots prepared for Chrome Web Store
- [ ] Promotional images created

## Post-Publication

After Chrome Web Store approval:

1. Update README.md with Chrome Web Store link
2. Create a blog post or announcement (optional)
3. Share on social media (optional)
4. Monitor GitHub issues for user feedback

## Support

For questions about packaging, see:
- [Chrome Web Store Developer Documentation](https://developer.chrome.com/docs/webstore/)
- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
