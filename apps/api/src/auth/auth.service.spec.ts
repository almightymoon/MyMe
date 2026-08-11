import { UnauthorizedException } from '@nestjs/common';
import { AuthService, DeviceInfo } from './auth.service';
import { IdentityTokenVerifier } from './identity/identity-token.verifier';
import { VerifiedIdentity } from './identity/verified-identity';
import { hashRefreshToken } from './crypto/refresh-token';

const device: DeviceInfo = {
  clientGeneratedDeviceId: 'device-client-aaaaaaaa',
  platform: 'ios',
  appVersion: '1.0.0',
};

function identity(
  provider: 'google' | 'apple',
  subject: string,
  email?: string,
): VerifiedIdentity {
  return {
    provider,
    subject,
    email,
    emailVerified: Boolean(email),
    displayName: provider === 'google' ? 'Ada' : undefined,
  };
}

function verifier(result: VerifiedIdentity): IdentityTokenVerifier {
  return { verify: async () => result };
}

describe('AuthService', () => {
  const pepper = 'memy-dev-refresh-pepper';
  const users: Record<string, Record<string, unknown>> = {};
  const identities: Array<Record<string, unknown>> = [];
  const devices: Array<Record<string, unknown>> = [];
  const sessions: Array<Record<string, unknown>> = [];
  let id = 1;

  const prisma: any = {
    authIdentity: {
      findUnique: jest.fn(
        async ({
          where,
        }: {
          where: {
            provider_providerSubject: {
              provider: string;
              providerSubject: string;
            };
          };
        }) => {
          return (
            identities.find(
              (row) =>
                row.provider === where.provider_providerSubject.provider &&
                row.providerSubject ===
                  where.provider_providerSubject.providerSubject,
            ) ?? null
          );
        },
      ),
      update: jest.fn(
        async ({
          where,
          data,
        }: {
          where: { id: string };
          data: Record<string, unknown>;
        }) => {
          const row = identities.find((item) => item.id === where.id)!;
          Object.assign(row, data);
          return row;
        },
      ),
    },
    user: {
      create: jest.fn(async ({ data }: { data: Record<string, unknown> }) => {
        const created = {
          id: `00000000-0000-4000-8000-00000000000${id++}`,
          displayName: data.displayName,
          email: data.email,
          avatarKey: null,
          timezone: 'UTC',
          currencyCode: 'PKR',
          status: 'active',
        };
        users[created.id] = created;
        const nested = data.identities as { create: Record<string, unknown> };
        identities.push({
          id: `id-${created.id}`,
          userId: created.id,
          ...nested.create,
        });
        return created;
      }),
      update: jest.fn(
        async ({
          where,
          data,
        }: {
          where: { id: string };
          data: Record<string, unknown>;
        }) => {
          Object.assign(users[where.id], data);
          return users[where.id];
        },
      ),
      findUniqueOrThrow: jest.fn(
        async ({ where }: { where: { id: string } }) => users[where.id],
      ),
    },
    device: {
      upsert: jest.fn(
        async ({
          where,
          create,
        }: {
          where: { userId_clientGeneratedDeviceId: { userId: string } };
          create: Record<string, unknown>;
        }) => {
          const existing = devices.find(
            (row) =>
              row.userId === where.userId_clientGeneratedDeviceId.userId &&
              row.clientGeneratedDeviceId === create.clientGeneratedDeviceId,
          );
          if (existing) return existing;
          const created = {
            id: `dev-${id++}`,
            ...create,
          };
          devices.push(created);
          return created;
        },
      ),
    },
    refreshSession: {
      create: jest.fn(async ({ data }: { data: Record<string, unknown> }) => {
        const created = { id: `sess-${id++}`, revokedAt: null, ...data };
        sessions.push(created);
        return created;
      }),
      findFirst: jest.fn(
        async ({ where }: { where: { tokenHash: string } }) => {
          const session = sessions.find(
            (row) => row.tokenHash === where.tokenHash,
          );
          if (!session) return null;
          const deviceRow = devices.find((row) => row.id === session.deviceId);
          return {
            ...session,
            device: deviceRow,
            user: users[session.userId as string],
          };
        },
      ),
      update: jest.fn(
        async ({
          where,
          data,
        }: {
          where: { id: string };
          data: Record<string, unknown>;
        }) => {
          const row = sessions.find((item) => item.id === where.id)!;
          Object.assign(row, data);
          return row;
        },
      ),
      updateMany: jest.fn(
        async ({
          where,
          data,
        }: {
          where: Record<string, unknown>;
          data: Record<string, unknown>;
        }) => {
          for (const row of sessions) {
            const familyMatch =
              !where.tokenFamilyId || row.tokenFamilyId === where.tokenFamilyId;
            const hashMatch =
              !where.tokenHash || row.tokenHash === where.tokenHash;
            const userMatch = !where.userId || row.userId === where.userId;
            const revokedMatch =
              where.revokedAt === null ? row.revokedAt == null : true;
            if (familyMatch && hashMatch && userMatch && revokedMatch) {
              Object.assign(row, data);
            }
          }
          return { count: 1 };
        },
      ),
    },
    $transaction: jest.fn(async (input: unknown) => {
      if (typeof input === 'function') {
        return (input as (tx: typeof prisma) => Promise<unknown>)(prisma);
      }
      return input;
    }),
  };

  const config = {
    get: jest.fn((key: string) => {
      if (key === 'auth') {
        return {
          accessSecret: 'memy-dev-access-secret-min-32-chars',
          refreshPepper: pepper,
        };
      }
      return undefined;
    }),
  };

  beforeEach(() => {
    for (const key of Object.keys(users)) delete users[key];
    identities.splice(0, identities.length);
    devices.splice(0, devices.length);
    sessions.splice(0, sessions.length);
    id = 1;
  });

  it('creates a new user for a new Google subject and does not seed records', async () => {
    const service = new AuthService(
      prisma as never,
      config as never,
      verifier(identity('google', 'sub-google', 'ada@example.com')),
      verifier(identity('apple', 'unused')),
    );
    const result = await service.signInWithGoogle('token', device);
    expect(result.bootstrapEmpty).toBe(true);
    expect(result.user.email).toBe('ada@example.com');
    expect(result.refreshToken).toBeTruthy();
    expect(sessions[0].tokenHash).toBe(
      hashRefreshToken(result.refreshToken, pepper),
    );
    expect(sessions[0].tokenHash).not.toEqual(result.refreshToken);
  });

  it('does not auto-link Google to an Apple user with the same email', async () => {
    const appleService = new AuthService(
      prisma as never,
      config as never,
      verifier(identity('google', 'unused')),
      verifier(identity('apple', 'sub-apple', 'shared@example.com')),
    );
    const apple = await appleService.signInWithApple('apple-token', device);
    const googleService = new AuthService(
      prisma as never,
      config as never,
      verifier(identity('google', 'sub-google', 'shared@example.com')),
      verifier(identity('apple', 'unused')),
    );
    const google = await googleService.signInWithGoogle('google-token', device);
    expect(google.user.id).not.toEqual(apple.user.id);
    expect(identities).toHaveLength(2);
  });

  it('rotates refresh tokens and revokes the family on reuse', async () => {
    const service = new AuthService(
      prisma as never,
      config as never,
      verifier(identity('google', 'sub-google', 'ada@example.com')),
      verifier(identity('apple', 'unused')),
    );
    const first = await service.signInWithGoogle('token', device);
    const rotated = await service.refresh(first.refreshToken, device);
    expect(rotated.refreshToken).not.toEqual(first.refreshToken);
    await expect(
      service.refresh(first.refreshToken, device),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(sessions.every((row) => row.revokedAt != null)).toBe(true);
  });
});
