#!/usr/bin/env bun

import { encodeMessage, extractUrl } from './protocol.js';

/**
 * Send a message to stdout using Chrome's native messaging protocol.
 * @param {object} message
 */
function sendMessage(message) {
  process.stdout.write(encodeMessage(message));
}

/**
 * Read a message from stdin using Chrome's native messaging protocol.
 * @returns {Promise<object>}
 */
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
    const result = extractUrl(message);

    if ('error' in result) {
      sendMessage({ success: false, error: result.error });
      process.exit(1);
    }

    // Open URL in default browser using Bun.spawn
    const proc = Bun.spawn(['open', result.url], {
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
  } catch (error) {
    sendMessage({ success: false, error: error.message });
    process.exit(1);
  }
}

main();
