import { UnauthorizedException } from '@nestjs/common';
import { createHash } from 'crypto';
import * as jose from 'jose';
import { IdentityTokenVerifier } from './identity-token.verifier';
import { VerifiedIdentity } from './verified-identity';

const APPLE_ISS = 'https://appleid.apple.com';

export class AppleTokenVerifier implements IdentityTokenVerifier {
  constructor(private readonly audience: string) {}

  async verify(idToken: string, nonce?: string): Promise<VerifiedIdentity> {
    try {
      const jwks = jose.createRemoteJWKSet(
        new URL('https://appleid.apple.com/auth/keys'),
      );
      const { payload } = await jose.jwtVerify(idToken, jwks, {
        issuer: APPLE_ISS,
        audience: this.audience,
      });
      if (!payload.sub || typeof payload.sub !== 'string') {
        throw new UnauthorizedException({
          code: 'APPLE_TOKEN_INVALID',
          message: 'Sign in again.',
        });
      }
      if (nonce) {
        const hashed = createHash('sha256').update(nonce).digest('hex');
        if (payload.nonce !== nonce && payload.nonce !== hashed) {
          throw new UnauthorizedException({
            code: 'APPLE_NONCE_MISMATCH',
            message: 'Sign in again.',
          });
        }
      }
      const email =
        typeof payload.email === 'string' ? payload.email : undefined;
      const verified =
        payload.email_verified === true || payload.email_verified === 'true';
      return {
        provider: 'apple',
        subject: payload.sub,
        email,
        emailVerified: verified,
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException({
        code: 'APPLE_TOKEN_INVALID',
        message: 'Sign in again.',
      });
    }
  }
}
