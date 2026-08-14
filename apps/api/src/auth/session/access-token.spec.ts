import { signAccessToken, verifyAccessToken } from './access-token';

describe('access-token', () => {
  const secret = 'memy-test-access-secret-min-32-chars';

  it('signs and verifies short-lived claims', () => {
    const { token } = signAccessToken(
      { sub: 'user-1', deviceId: 'device-1', ver: 1 },
      secret,
      60,
    );
    const claims = verifyAccessToken(token, secret);
    expect(claims.sub).toBe('user-1');
    expect(claims.deviceId).toBe('device-1');
    expect(claims.ver).toBe(1);
  });

  it('rejects a bad signature', () => {
    const { token } = signAccessToken(
      { sub: 'user-1', deviceId: 'device-1', ver: 1 },
      secret,
      60,
    );
    expect(() =>
      verifyAccessToken(token, 'wrong-secret-min-32-characters!!'),
    ).toThrow('INVALID_ACCESS_TOKEN');
  });
});
