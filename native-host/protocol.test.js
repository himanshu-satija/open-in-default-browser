import { describe, test, expect } from 'bun:test';
import { encodeMessage, decodeMessage, extractUrl } from './protocol.js';

// ─── encodeMessage ───────────────────────────────────────────────────────────

describe('encodeMessage', () => {
  test('produces a 4-byte LE header followed by JSON', () => {
    const buf = encodeMessage({ success: true });
    const length = buf.readUInt32LE(0);
    const body = buf.slice(4).toString();

    expect(length).toBe(body.length);
    expect(JSON.parse(body)).toEqual({ success: true });
  });

  test('handles empty object', () => {
    const buf = encodeMessage({});
    const length = buf.readUInt32LE(0);
    expect(length).toBe(2); // "{}"
    expect(buf.slice(4).toString()).toBe('{}');
  });

  test('handles unicode characters', () => {
    const msg = { text: '日本語テスト 🚀' };
    const buf = encodeMessage(msg);
    const length = buf.readUInt32LE(0);
    const body = buf.slice(4, 4 + length).toString();
    expect(JSON.parse(body)).toEqual(msg);
  });

  test('handles nested objects', () => {
    const msg = { data: { url: 'https://example.com', meta: { count: 42 } } };
    const buf = encodeMessage(msg);
    const decoded = JSON.parse(buf.slice(4).toString());
    expect(decoded).toEqual(msg);
  });
});

// ─── decodeMessage ───────────────────────────────────────────────────────────

describe('decodeMessage', () => {
  test('round-trips with encodeMessage', () => {
    const original = { url: 'https://example.com' };
    const encoded = encodeMessage(original);
    const { message, bytesConsumed } = decodeMessage(encoded);

    expect(message).toEqual(original);
    expect(bytesConsumed).toBe(encoded.length);
  });

  test('throws on buffer shorter than 4 bytes', () => {
    expect(() => decodeMessage(Buffer.from([0x01, 0x02]))).toThrow('too short');
  });

  test('throws on zero-length message', () => {
    const buf = Buffer.alloc(4);
    buf.writeUInt32LE(0, 0);
    expect(() => decodeMessage(buf)).toThrow('length is 0');
  });

  test('throws on incomplete body', () => {
    const header = Buffer.alloc(4);
    header.writeUInt32LE(100, 0); // claims 100 bytes
    const body = Buffer.from('{}'); // only 2 bytes
    const buf = Buffer.concat([header, body]);

    expect(() => decodeMessage(buf)).toThrow('Incomplete');
  });

  test('throws on malformed JSON', () => {
    const garbage = Buffer.from('not json!!');
    const header = Buffer.alloc(4);
    header.writeUInt32LE(garbage.length, 0);
    const buf = Buffer.concat([header, garbage]);

    expect(() => decodeMessage(buf)).toThrow();
  });

  test('handles large messages', () => {
    const bigUrl = 'https://example.com/' + 'a'.repeat(10000);
    const original = { url: bigUrl };
    const encoded = encodeMessage(original);
    const { message } = decodeMessage(encoded);
    expect(message).toEqual(original);
  });
});

// ─── extractUrl ──────────────────────────────────────────────────────────────

describe('extractUrl', () => {
  test('extracts a valid http URL', () => {
    expect(extractUrl({ url: 'http://example.com' })).toEqual({
      url: 'http://example.com',
    });
  });

  test('extracts a valid https URL', () => {
    expect(extractUrl({ url: 'https://example.com/path?q=1' })).toEqual({
      url: 'https://example.com/path?q=1',
    });
  });

  test('returns error for missing url field', () => {
    const result = extractUrl({ foo: 'bar' });
    expect(result).toHaveProperty('error');
    expect(result.error).toMatch(/no url/i);
  });

  test('returns error for empty url string', () => {
    const result = extractUrl({ url: '' });
    expect(result).toHaveProperty('error');
  });

  test('returns error for non-string url', () => {
    const result = extractUrl({ url: 12345 });
    expect(result).toHaveProperty('error');
  });

  test('returns error for null message', () => {
    const result = extractUrl(null);
    expect(result).toHaveProperty('error');
    expect(result.error).toMatch(/invalid/i);
  });

  test('returns error for undefined message', () => {
    const result = extractUrl(undefined);
    expect(result).toHaveProperty('error');
  });

  test('rejects non-http(s) schemes', () => {
    const result = extractUrl({ url: 'javascript:alert(1)' });
    expect(result).toHaveProperty('error');
    expect(result.error).toMatch(/scheme/i);
  });

  test('rejects file:// scheme', () => {
    const result = extractUrl({ url: 'file:///etc/passwd' });
    expect(result).toHaveProperty('error');
  });

  test('is case-insensitive for scheme', () => {
    expect(extractUrl({ url: 'HTTPS://EXAMPLE.COM' })).toEqual({
      url: 'HTTPS://EXAMPLE.COM',
    });
  });
});

// ─── encode → decode round-trip ──────────────────────────────────────────────

describe('round-trip', () => {
  const cases = [
    { url: 'https://example.com' },
    { success: true },
    { success: false, error: 'something went wrong' },
    { url: 'https://example.com/path?q=hello+world&lang=en' },
  ];

  for (const original of cases) {
    test(`round-trips ${JSON.stringify(original)}`, () => {
      const encoded = encodeMessage(original);
      const { message } = decodeMessage(encoded);
      expect(message).toEqual(original);
    });
  }
});
