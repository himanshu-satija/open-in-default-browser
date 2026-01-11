# Native Messaging Host

This directory contains the native messaging host that handles opening URLs in the default browser.

## Files

- **host.js** - Source code for the native messaging host
- **host-binary** - Compiled Bun executable (not in git, must be built)

## Building

To compile the native messaging host to a standalone executable:

```bash
# Install Bun if not already installed
curl -fsSL https://bun.sh/install | bash

# Compile host.js to binary
bun build --compile --minify --sourcemap ./host.js --outfile host-binary
```

The resulting `host-binary` file is a standalone executable (~60MB) that includes the Bun runtime and has zero external dependencies.

## Development Testing

For local development and testing with an unpacked Chrome extension:

### Quick Setup

Use the `install-dev.sh` script from the project root to automatically install the native host:

```bash
# From the project root directory
../install-dev.sh YOUR_EXTENSION_ID
```

The script will:
- Copy `host-binary` to the Chrome NativeMessagingHosts directory
- Create the manifest file with your extension ID
- Set proper permissions

### Getting Your Extension ID

1. Open `chrome://extensions/` in Chrome
2. Enable "Developer mode"
3. Load the extension unpacked
4. Copy the 32-character Extension ID

### Manual Testing

You can test the native host directly using the native messaging protocol:

```bash
echo '{"url":"https://example.com"}' | node -e '
const msg = require("fs").readFileSync(0, "utf-8");
const msgBuf = Buffer.from(msg);
const header = Buffer.alloc(4);
header.writeUInt32LE(msgBuf.length, 0);
process.stdout.write(header);
process.stdout.write(msgBuf);
' | ./host-binary
```

Should return `{"success":true}` and open example.com in your default browser.

For complete development workflow and troubleshooting, see [../DEVELOPMENT.md](../DEVELOPMENT.md).

## How It Works

The native messaging host:
1. Reads messages from Chrome via stdin (native messaging protocol)
2. Extracts the URL from the message
3. Uses macOS `open` command to open the URL in the default browser
4. Sends a success/error response back to Chrome via stdout

## Protocol

Chrome's native messaging protocol:
- Messages are prefixed with 4-byte length (little-endian)
- The message body is JSON
- Communication happens over stdin/stdout

## Integration

The compiled `host-binary` is bundled inside the companion app at:
```
Open in Default Browser.app/Contents/Resources/host-binary
```

The companion app copies it to:
```
~/Library/Application Support/Google/Chrome/NativeMessagingHosts/open-in-default-browser-host
```

And creates a manifest file that points to this location.
