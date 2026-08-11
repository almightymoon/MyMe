import { generateOpaqueRefreshToken, hashRefreshToken } from './refresh-token';

describe('refresh-token', () => {
  it('hashes with pepper and never returns the raw token', () => {
    const raw = generateOpaqueRefreshToken();
    const hash = hashRefreshToken(raw, 'pepper');
    expect(hash).not.toEqual(raw);
    expect(hash).toHaveLength(64);
    expect(hashRefreshToken(raw, 'pepper')).toEqual(hash);
    expect(hashRefreshToken(raw, 'other')).not.toEqual(hash);
  });
});
