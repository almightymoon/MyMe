import { createHmac, randomBytes, scryptSync, timingSafeEqual } from 'crypto';

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

export type AdminAccessTokenClaims = {
  sub: string;
  typ: 'admin';
  ver: number;
  iat: number;
  exp: number;
};

function encode(input: object): string {
  return Buffer.from(JSON.stringify(input)).toString('base64url');
}

export function signAdminAccessToken(
  claims: Omit<AdminAccessTokenClaims, 'iat' | 'exp' | 'typ'>,
  secret: string,
  ttlSeconds: number,
): { token: string; expiresAt: Date } {
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + ttlSeconds;
  const payload: AdminAccessTokenClaims = {
    ...claims,
    typ: 'admin',
    iat,
    exp,
  };
  const header = encode({ alg: 'HS256', typ: 'JWT' });
  const body = encode(payload);
  const signature = createHmac('sha256', secret)
    .update(`${header}.${body}`)
    .digest('base64url');
  return {
    token: `${header}.${body}.${signature}`,
    expiresAt: new Date(exp * 1000),
  };
}

export function verifyAdminAccessToken(
  token: string,
  secret: string,
): AdminAccessTokenClaims {
  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('INVALID_ADMIN_TOKEN');
  }
  const [header, body, signature] = parts;
  const expected = createHmac('sha256', secret)
    .update(`${header}.${body}`)
    .digest('base64url');
  const expectedBuffer = Buffer.from(expected);
  const actualBuffer = Buffer.from(signature);
  if (
    expectedBuffer.length !== actualBuffer.length ||
    !timingSafeEqual(expectedBuffer, actualBuffer)
  ) {
    throw new Error('INVALID_ADMIN_TOKEN');
  }
  const claims = JSON.parse(
    Buffer.from(body, 'base64url').toString('utf8'),
  ) as AdminAccessTokenClaims;
  if (!claims.sub || claims.typ !== 'admin' || !claims.exp) {
    throw new Error('INVALID_ADMIN_TOKEN');
  }
  if (claims.exp * 1000 <= Date.now()) {
    throw new Error('EXPIRED_ADMIN_TOKEN');
  }
  return claims;
}
