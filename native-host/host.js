#!/usr/bin/env bun

// Send a message to stdout using Chrome's native messaging protocol
function sendMessage(message) {
  const messageStr = JSON.stringify(message);
  const messageBuffer = Buffer.from(messageStr);
  const header = Buffer.alloc(4);
  header.writeUInt32LE(messageBuffer.length, 0);

  process.stdout.write(header);
  process.stdout.write(messageBuffer);
}

// Read a message from stdin using Chrome's native messaging protocol
function readMessage() {
  return new Promise((resolve, reject) => {
    let headerBuffer = Buffer.alloc(0);
    let messageBuffer = Buffer.alloc(0);
    let messageLength = null;

    process.stdin.on('readable', () => {
      let chunk;

      // Read the 4-byte header first
      if (messageLength === null) {
        while (headerBuffer.length < 4 && (chunk = process.stdin.read(1)) !== null) {
          headerBuffer = Buffer.concat([headerBuffer, chunk]);
        }

        if (headerBuffer.length === 4) {
          messageLength = headerBuffer.readUInt32LE(0);
        }
      }

      // Read the message body
      if (messageLength !== null) {
        while (messageBuffer.length < messageLength && (chunk = process.stdin.read()) !== null) {
          messageBuffer = Buffer.concat([messageBuffer, chunk]);
        }

        if (messageBuffer.length === messageLength) {
          try {
            const message = JSON.parse(messageBuffer.toString());
            resolve(message);
          } catch (error) {
            reject(error);
          }
        }
      }
    });

    process.stdin.on('error', reject);
  });
}

// Main function
async function main() {
  try {
    // Read message from Chrome extension
    const message = await readMessage();

    if (message?.url) {
      // Open URL in default browser using Bun.spawn
      const proc = Bun.spawn(['open', message.url], {
        stdout: 'ignore',
        stderr: 'pipe',
      });

      const exitCode = await proc.exited;

      if (exitCode === 0) {
        sendMessage({ success: true });
        process.exit(0);
      } else {
        const errorText = await new Response(proc.stderr).text();
        sendMessage({ success: false, error: errorText || 'Failed to open URL' });
        process.exit(1);
      }
    } else {
      sendMessage({ success: false, error: 'No URL provided' });
      process.exit(1);
    }
  } catch (error) {
    sendMessage({ success: false, error: error.message });
    process.exit(1);
  }
}

main();
