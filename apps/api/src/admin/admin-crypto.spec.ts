import {
  hashPassword,
  signAdminAccessToken,
  verifyAdminAccessToken,
  verifyPassword,
} from './admin-crypto';

describe('admin-crypto', () => {
  it('hashes and verifies passwords', () => {
    const stored = hashPassword('a-strong-admin-pass');
    expect(verifyPassword('a-strong-admin-pass', stored)).toBe(true);
    expect(verifyPassword('wrong-password!!', stored)).toBe(false);
  });

  it('signs and verifies admin tokens', () => {
    const secret = 'memy-test-access-secret-min-32-chars';
    const { token } = signAdminAccessToken(
      { sub: 'admin-1', ver: 1 },
      secret,
      60,
    );
    const claims = verifyAdminAccessToken(token, secret);
    expect(claims.sub).toBe('admin-1');
    expect(claims.typ).toBe('admin');
  });

  it('rejects a user-shaped token missing typ=admin', () => {
    const secret = 'memy-test-access-secret-min-32-chars';
    expect(() => verifyAdminAccessToken('not.a.jwt', secret)).toThrow(
      'INVALID_ADMIN_TOKEN',
    );
  });
});
