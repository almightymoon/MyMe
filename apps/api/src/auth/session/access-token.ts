import { createHmac, timingSafeEqual } from 'crypto';

export type AccessTokenClaims = {
  sub: string;
  deviceId: string;
  ver: number;
  iat: number;
  exp: number;
};

function encode(input: object): string {
  return Buffer.from(JSON.stringify(input)).toString('base64url');
}

export function signAccessToken(
  claims: Omit<AccessTokenClaims, 'iat' | 'exp'>,
  secret: string,
  ttlSeconds: number,
): { token: string; expiresAt: Date } {
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + ttlSeconds;
  const payload: AccessTokenClaims = {
    ...claims,
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

export function verifyAccessToken(
  token: string,
  secret: string,
): AccessTokenClaims {
  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('INVALID_ACCESS_TOKEN');
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
    throw new Error('INVALID_ACCESS_TOKEN');
  }
  const claims = JSON.parse(
    Buffer.from(body, 'base64url').toString('utf8'),
  ) as AccessTokenClaims;
  if (!claims.sub || !claims.deviceId || !claims.exp) {
    throw new Error('INVALID_ACCESS_TOKEN');
  }
  if (claims.exp * 1000 <= Date.now()) {
    throw new Error('EXPIRED_ACCESS_TOKEN');
  }
  return claims;
}
