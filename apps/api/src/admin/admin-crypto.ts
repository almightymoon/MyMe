import { createHmac, timingSafeEqual } from 'crypto';

export { hashPassword, verifyPassword } from '../crypto/password';

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
