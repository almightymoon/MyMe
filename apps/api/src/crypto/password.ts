import { randomBytes, scryptSync, timingSafeEqual } from 'crypto';

const SCRYPT_N = 16384;
const SCRYPT_R = 8;
const SCRYPT_P = 1;
const KEY_LEN = 32;

export function hashPassword(plain: string): string {
  const salt = randomBytes(16).toString('base64url');
  const derived = scryptSync(plain, salt, KEY_LEN, {
    N: SCRYPT_N,
    r: SCRYPT_R,
    p: SCRYPT_P,
  });
  return `scrypt$${SCRYPT_N}$${SCRYPT_R}$${SCRYPT_P}$${salt}$${derived.toString('base64url')}`;
}

export function verifyPassword(plain: string, stored: string): boolean {
  const parts = stored.split('$');
  if (parts.length !== 6 || parts[0] !== 'scrypt') {
    return false;
  }
  const n = Number(parts[1]);
  const r = Number(parts[2]);
  const p = Number(parts[3]);
  const salt = parts[4];
  const expected = parts[5];
  if (!n || !r || !p || !salt || !expected) {
    return false;
  }
  const derived = scryptSync(plain, salt, KEY_LEN, { N: n, r, p });
  const actual = Buffer.from(derived.toString('base64url'));
  const want = Buffer.from(expected);
  if (actual.length !== want.length) {
    return false;
  }
  return timingSafeEqual(actual, want);
}
