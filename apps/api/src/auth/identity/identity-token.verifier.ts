import { VerifiedIdentity } from './verified-identity';

export const GOOGLE_TOKEN_VERIFIER = Symbol('GOOGLE_TOKEN_VERIFIER');
export const APPLE_TOKEN_VERIFIER = Symbol('APPLE_TOKEN_VERIFIER');

export interface IdentityTokenVerifier {
  verify(idToken: string, nonce?: string): Promise<VerifiedIdentity>;
}
