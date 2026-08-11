import { UnauthorizedException } from '@nestjs/common';
import { OAuth2Client } from 'google-auth-library';
import { IdentityTokenVerifier } from './identity-token.verifier';
import { VerifiedIdentity } from './verified-identity';

export class GoogleTokenVerifier implements IdentityTokenVerifier {
  private readonly client = new OAuth2Client();

  constructor(private readonly audience: string) {}

  async verify(idToken: string, nonce?: string): Promise<VerifiedIdentity> {
    try {
      const ticket = await this.client.verifyIdToken({
        idToken,
        audience: this.audience,
      });
      const payload = ticket.getPayload();
      if (!payload?.sub) {
        throw new UnauthorizedException({
          code: 'GOOGLE_TOKEN_INVALID',
          message: 'Sign in again.',
        });
      }
      if (nonce && payload.nonce && payload.nonce !== nonce) {
        throw new UnauthorizedException({
          code: 'GOOGLE_NONCE_MISMATCH',
          message: 'Sign in again.',
        });
      }
      return {
        provider: 'google',
        subject: payload.sub,
        email: payload.email,
        emailVerified: payload.email_verified === true,
        displayName: payload.name,
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException({
        code: 'GOOGLE_TOKEN_INVALID',
        message: 'Sign in again.',
      });
    }
  }
}
