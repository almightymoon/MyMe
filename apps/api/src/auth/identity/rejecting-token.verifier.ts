import { UnauthorizedException } from '@nestjs/common';
import { IdentityTokenVerifier } from './identity-token.verifier';
import { VerifiedIdentity } from './verified-identity';

/** Used until owner OAuth clients are configured. Never accepts a token. */
export class RejectingTokenVerifier implements IdentityTokenVerifier {
  constructor(private readonly provider: 'google' | 'apple') {}

  async verify(): Promise<VerifiedIdentity> {
    throw new UnauthorizedException({
      code: 'IDENTITY_PROVIDER_UNCONFIGURED',
      message: `${this.provider} token verification is not configured on this API.`,
    });
  }
}
