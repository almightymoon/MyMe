export type AuthProviderName = 'google' | 'apple';

export type VerifiedIdentity = {
  provider: AuthProviderName;
  subject: string;
  email?: string;
  emailVerified: boolean;
  displayName?: string;
};
