# Privacy Policy for Open in Default Browser

**Last Updated:** August 2026

## Overview

Open in Default Browser is a Chrome extension that allows users to open links in their system's default browser via a right-click context menu. This privacy policy explains how the extension handles user data.

## Data Collection

**This extension does NOT collect, store, or transmit any user data.**

Specifically:

- We do not collect browsing history
- We do not collect personal information
- We do not collect URLs you click on
- We do not track user behavior
- We do not use analytics or tracking services
- We do not use cookies

## How the Extension Works

1. When you right-click on a link and select "Open in default browser", the extension:

   - Receives the URL of the link you clicked
   - Sends the URL to a locally-installed native host binary on your computer
   - The native host opens the URL in your system's default browser using the macOS `open` command

2. All processing happens locally on your machine
3. No data ever leaves your computer to external servers
4. No data is stored persistently by the extension

## Permissions

The extension requests the following permissions:

### contextMenus

- **Purpose:** To add the "Open in default browser" option to the right-click menu on links
- **Data Access:** None. This permission only allows creating menu items.

### nativeMessaging

- **Purpose:** To communicate with the locally-installed native host binary that opens URLs in your default browser
- **Data Access:** The extension only sends URLs to the local native host. No data is sent to external servers.

### notifications

- **Purpose:** To display error messages when something goes wrong (e.g., native host not installed)
- **Data Access:** None. Notifications only display locally on your computer.

## Third-Party Services

This extension does not use any third-party services, APIs, or analytics tools.

## Data Storage

This extension does not store any data locally or remotely.

## Changes to URLs

The extension does not modify, log, or store any URLs. It simply passes them to the local native host binary for opening in your default browser.

## Children's Privacy

This extension does not knowingly collect any information from children. It does not collect information from anyone.

## Open Source

This extension is open source. You can review the complete source code at:
https://github.com/himanshu-satija/open-in-default-browser

## Changes to This Privacy Policy

We may update this privacy policy from time to time. We will notify users of any changes by updating the "Last Updated" date at the top of this policy.

## Contact

If you have questions about this privacy policy, please open an issue on our GitHub repository:
https://github.com/himanshu-satija/open-in-default-browser/issues

## Your Consent

By using this extension, you consent to this privacy policy.

## Summary

**In plain English:** This extension doesn't collect, store, or transmit any of your data. It only helps you open links in your default browser. Everything happens locally on your computer.
