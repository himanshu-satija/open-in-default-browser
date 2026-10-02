import { describe, test, expect, beforeAll } from 'bun:test';
import { encodeMessage, decodeMessage } from '../../native-host/protocol.js';
import { existsSync } from 'fs';
import { resolve } from 'path';

const HOST_BINARY = resolve(import.meta.dir, '../../native-host/host-binary');

/**
 * Send a native-messaging request to host-binary and return the parsed response.
 * Does NOT actually open the URL — we check the response only.
 */
async function sendToHost(payload) {
  const input = encodeMessage(payload);

  const proc = Bun.spawn([HOST_BINARY], {
    stdin: new Blob([input]),
    stdout: 'pipe',
    stderr: 'pipe',
  });

  // Read all stdout
  const rawOut = await new Response(proc.stdout).arrayBuffer();
  const exitCode = await proc.exited;

  if (rawOut.byteLength === 0) {
    const stderrText = await new Response(proc.stderr).text();
    return { exitCode, response: null, stderr: stderrText };
  }

  const { message } = decodeMessage(Buffer.from(rawOut));
  return { exitCode, response: message, stderr: '' };
}

// ─────────────────────────────────────────────────────────────────────────────

describe('native host binary (integration)', () => {
  beforeAll(() => {
    if (!existsSync(HOST_BINARY)) {
      throw new Error(
        `host-binary not found at ${HOST_BINARY}.\n` +
          'Build it first: cd native-host && bun build --compile --minify --sourcemap ./host.js --outfile host-binary'
      );
    }
  });

  test('responds with success:true for a valid https URL', async () => {
    // This will actually open a browser tab — acceptable in integration tests
    const { exitCode, response } = await sendToHost({
      url: 'https://example.com',
    });

    expect(response).toBeDefined();
    expect(response.success).toBe(true);
    expect(exitCode).toBe(0);
  });

  test('responds with error when no URL is provided', async () => {
    const { exitCode, response } = await sendToHost({ foo: 'bar' });

    expect(response).toBeDefined();
    expect(response.success).toBe(false);
    expect(response.error).toBeDefined();
    expect(exitCode).not.toBe(0);
  });

  test('responds with error for empty message', async () => {
    const { exitCode, response } = await sendToHost({});

    expect(response).toBeDefined();
    expect(response.success).toBe(false);
    expect(exitCode).not.toBe(0);
  });

  test('responds with error for non-http URL scheme', async () => {
    const { exitCode, response } = await sendToHost({
      url: 'javascript:alert(1)',
    });

    expect(response).toBeDefined();
    expect(response.success).toBe(false);
    expect(response.error).toBeDefined();
    expect(exitCode).not.toBe(0);
  });
});
