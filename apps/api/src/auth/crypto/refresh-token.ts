import { createHash, randomBytes } from 'crypto';

export function generateOpaqueRefreshToken(): string {
  return randomBytes(32).toString('base64url');
}

export function hashRefreshToken(token: string, pepper: string): string {
  return createHash('sha256').update(`${pepper}:${token}`).digest('hex');
}

export function generateDeviceFamilyId(): string {
  return randomBytes(16).toString('hex');
}
