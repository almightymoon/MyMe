import { UnauthorizedException } from '@nestjs/common';
import { createHash } from 'crypto';
import type { createRemoteJWKSet } from 'jose';
import { IdentityTokenVerifier } from './identity-token.verifier';
import { VerifiedIdentity } from './verified-identity';

const APPLE_ISS = 'https://appleid.apple.com';
const APPLE_JWKS_URL = new URL('https://appleid.apple.com/auth/keys');

type JoseModule = typeof import('jose');
type RemoteJWKSet = ReturnType<typeof createRemoteJWKSet>;

export class AppleTokenVerifier implements IdentityTokenVerifier {
  private jwks?: RemoteJWKSet;
  private josePromise?: Promise<JoseModule>;

  constructor(private readonly audience: string) {}

  /** Dynamic import keeps Jest (CJS) from parsing jose's ESM bundle at load time. */
  private loadJose(): Promise<JoseModule> {
    this.josePromise ??= import('jose');
    return this.josePromise;
  }

  private async getJwks(): Promise<RemoteJWKSet> {
    if (!this.jwks) {
      const jose = await this.loadJose();
      this.jwks = jose.createRemoteJWKSet(APPLE_JWKS_URL);
    }
    return this.jwks;
  }

  async verify(idToken: string, nonce?: string): Promise<VerifiedIdentity> {
    try {
      const jose = await this.loadJose();
      const { payload } = await jose.jwtVerify(idToken, await this.getJwks(), {
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
