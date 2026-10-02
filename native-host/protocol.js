/**
 * Chrome Native Messaging Protocol helpers.
 *
 * The wire format is:
 *   [4-byte LE uint32 length][JSON payload]
 *
 * These functions are intentionally side-effect-free so they can be
 * unit-tested without touching stdin/stdout.
 */

/**
 * Encode a JS object into a native-messaging wire-format Buffer.
 * @param {object} message
 * @returns {Buffer}
 */
export function encodeMessage(message) {
  const json = JSON.stringify(message);
  const body = Buffer.from(json);
  const header = Buffer.alloc(4);
  header.writeUInt32LE(body.length, 0);
  return Buffer.concat([header, body]);
}

/**
 * Decode a native-messaging wire-format Buffer into a JS object.
 *
 * @param {Buffer} raw  — full buffer (header + body)
 * @returns {{ message: object, bytesConsumed: number }}
 * @throws if the buffer is too short or JSON is malformed.
 */
export function decodeMessage(raw) {
  if (raw.length < 4) {
    throw new Error(`Buffer too short for header: need 4 bytes, got ${raw.length}`);
  }

  const length = raw.readUInt32LE(0);

  if (length === 0) {
    throw new Error('Message length is 0');
  }

  if (raw.length < 4 + length) {
    throw new Error(
      `Incomplete message: header says ${length} bytes, but only ${raw.length - 4} available`
    );
  }

  const json = raw.slice(4, 4 + length).toString();
  const message = JSON.parse(json);
  return { message, bytesConsumed: 4 + length };
}

/**
 * Validate an incoming message and return the URL to open, or an error string.
 * @param {unknown} message
 * @returns {{ url: string } | { error: string }}
 */
export function extractUrl(message) {
  if (message === null || message === undefined || typeof message !== 'object') {
    return { error: 'Invalid message format' };
  }

  const url = /** @type {any} */ (message).url;

  if (typeof url !== 'string' || url.length === 0) {
    return { error: 'No URL provided' };
  }

  // Basic sanity check — must look like a URL
  if (!/^https?:\/\//i.test(url)) {
    return { error: `Invalid URL scheme: ${url}` };
  }

  return { url };
}
