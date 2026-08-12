import { Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthProvider } from '@prisma/client';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { AppConfig } from '../config/configuration';
import {
  generateOpaqueRefreshToken,
  hashRefreshToken,
} from './crypto/refresh-token';
import {
  APPLE_TOKEN_VERIFIER,
  GOOGLE_TOKEN_VERIFIER,
  IdentityTokenVerifier,
} from './identity/identity-token.verifier';
import { VerifiedIdentity } from './identity/verified-identity';
import { signAccessToken } from './session/access-token';

const ACCESS_TTL_SECONDS = 15 * 60;
const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;

export type DeviceInfo = {
  clientGeneratedDeviceId: string;
  platform: string;
  appVersion: string;
  deviceLabel?: string;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService<AppConfig, true>,
    @Inject(GOOGLE_TOKEN_VERIFIER)
    private readonly googleVerifier: IdentityTokenVerifier,
    @Inject(APPLE_TOKEN_VERIFIER)
    private readonly appleVerifier: IdentityTokenVerifier,
  ) {}

  async signInWithGoogle(idToken: string, device: DeviceInfo, nonce?: string) {
    const identity = await this.googleVerifier.verify(idToken, nonce);
    return this.completeSignIn(identity, device);
  }

  async signInWithApple(
    idToken: string,
    device: DeviceInfo,
    nonce?: string,
    firstAuthorizationName?: string,
  ) {
    const identity = await this.appleVerifier.verify(idToken, nonce);
    if (firstAuthorizationName?.trim()) {
      identity.displayName = firstAuthorizationName.trim();
    }
    return this.completeSignIn(identity, device);
  }

  async refresh(refreshToken: string, device: DeviceInfo) {
    const pepper = this.refreshPepper();
    const tokenHash = hashRefreshToken(refreshToken, pepper);
    const session = await this.prisma.refreshSession.findFirst({
      where: { tokenHash },
      include: { device: true, user: true },
    });
    if (!session) {
      throw new UnauthorizedException({
        code: 'REFRESH_INVALID',
        message: 'Sign in again to sync.',
      });
    }
    if (session.revokedAt) {
      await this.prisma.refreshSession.updateMany({
        where: { tokenFamilyId: session.tokenFamilyId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException({
        code: 'REFRESH_REUSE',
        message: 'Sign in again to sync.',
      });
    }
    if (session.expiresAt <= new Date()) {
      throw new UnauthorizedException({
        code: 'REFRESH_INVALID',
        message: 'Sign in again to sync.',
      });
    }
    if (
      session.device.clientGeneratedDeviceId !== device.clientGeneratedDeviceId
    ) {
      throw new UnauthorizedException({
        code: 'REFRESH_DEVICE_MISMATCH',
        message: 'Sign in again to sync.',
      });
    }

    const nextRaw = generateOpaqueRefreshToken();
    const nextHash = hashRefreshToken(nextRaw, pepper);
    const familyId = session.tokenFamilyId;

    await this.prisma.$transaction(async (tx) => {
      await tx.refreshSession.update({
        where: { id: session.id },
        data: { revokedAt: new Date(), rotatedAt: new Date() },
      });
      await tx.refreshSession.create({
        data: {
          userId: session.userId,
          deviceId: session.deviceId,
          tokenHash: nextHash,
          tokenFamilyId: familyId,
          expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
        },
      });
    });

    return this.issueAccess(session.userId, session.deviceId, nextRaw);
  }

  async logout(refreshToken: string) {
    const tokenHash = hashRefreshToken(refreshToken, this.refreshPepper());
    await this.prisma.refreshSession.updateMany({
      where: { tokenHash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async logoutAll(userId: string) {
    await this.prisma.refreshSession.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
    });
    return {
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      avatarKey: user.avatarKey,
      timezone: user.timezone,
      currencyCode: user.currencyCode,
      status: user.status,
    };
  }

  async listDevices(userId: string) {
    return this.prisma.device.findMany({
      where: { userId, revokedAt: null },
      select: {
        id: true,
        platform: true,
        appVersion: true,
        deviceLabel: true,
        lastSeenAt: true,
        createdAt: true,
      },
      orderBy: { lastSeenAt: 'desc' },
    });
  }

  async revokeDevice(userId: string, deviceId: string) {
    const device = await this.prisma.device.findFirst({
      where: { id: deviceId, userId },
    });
    if (!device) {
      throw new UnauthorizedException({
        code: 'DEVICE_NOT_FOUND',
        message: 'Device not found.',
      });
    }
    await this.prisma.$transaction([
      this.prisma.device.update({
        where: { id: deviceId },
        data: { revokedAt: new Date() },
      }),
      this.prisma.refreshSession.updateMany({
        where: { deviceId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);
  }

  async deleteAccount(userId: string) {
    await this.prisma.$transaction(async (tx) => {
      await tx.refreshSession.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      await tx.asset.updateMany({
        where: { userId, deletedAt: null },
        data: {
          deletedAt: new Date(),
          uploadStatus: 'deletionPending',
        },
      });
      await tx.user.update({
        where: { id: userId },
        data: {
          status: 'deletionPending',
          deletedAt: new Date(),
          displayName: 'Deleted account',
          email: null,
          avatarKey: null,
        },
      });
      await tx.syncRecord.deleteMany({ where: { userId } });
      await tx.syncChangeLog.deleteMany({ where: { userId } });
      await tx.syncMutationReceipt.deleteMany({ where: { userId } });
      await tx.goal.deleteMany({ where: { userId } });
      await tx.authIdentity.deleteMany({ where: { userId } });
    });
  }

  async exportAccount(userId: string) {
    const [user, records, assets] = await Promise.all([
      this.prisma.user.findUniqueOrThrow({ where: { id: userId } }),
      this.prisma.syncRecord.findMany({
        where: { userId, deletedAt: null },
      }),
      this.prisma.asset.findMany({
        where: { userId, deletedAt: null },
        select: {
          id: true,
          kind: true,
          mimeType: true,
          byteSize: true,
          version: true,
          uploadStatus: true,
          createdAt: true,
        },
      }),
    ]);
    return {
      manifestVersion: 1,
      exportedAt: new Date().toISOString(),
      dataSources: {
        backend: true,
        health: false,
        importedCalendar: false,
      },
      user: {
        id: user.id,
        displayName: user.displayName,
        email: user.email,
        avatarKey: user.avatarKey,
        timezone: user.timezone,
        currencyCode: user.currencyCode,
      },
      records: records.map((row) => ({
        entityType: row.entityType,
        entityId: row.entityId,
        serverVersion: row.serverVersion,
        payload: row.payload,
        updatedAt: row.updatedAt.toISOString(),
      })),
      assets,
    };
  }

  /**
   * Email matching another provider must not link accounts.
   * Identity is provider + subject only.
   */
  async completeSignIn(identity: VerifiedIdentity, device: DeviceInfo) {
    const provider = identity.provider as AuthProvider;
    const existing = await this.prisma.authIdentity.findUnique({
      where: {
        provider_providerSubject: {
          provider,
          providerSubject: identity.subject,
        },
      },
    });

    let userId: string;
    if (existing) {
      userId = existing.userId;
      await this.prisma.authIdentity.update({
        where: { id: existing.id },
        data: {
          lastUsedAt: new Date(),
          providerEmail: identity.email,
          emailVerified: identity.emailVerified,
        },
      });
      if (identity.displayName?.trim()) {
        const current = await this.prisma.user.findUniqueOrThrow({
          where: { id: userId },
        });
        if (current.displayName === 'MeMy member') {
          await this.prisma.user.update({
            where: { id: userId },
            data: { displayName: identity.displayName.trim() },
          });
        }
      }
    } else {
      const created = await this.prisma.user.create({
        data: {
          displayName: identity.displayName?.trim() || 'MeMy member',
          email: identity.email,
          lastSignedInAt: new Date(),
          identities: {
            create: {
              provider,
              providerSubject: identity.subject,
              providerEmail: identity.email,
              emailVerified: identity.emailVerified,
            },
          },
        },
      });
      userId = created.id;
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { lastSignedInAt: new Date(), deletedAt: null, status: 'active' },
    });

    const persistedDevice = await this.prisma.device.upsert({
      where: {
        userId_clientGeneratedDeviceId: {
          userId,
          clientGeneratedDeviceId: device.clientGeneratedDeviceId,
        },
      },
      update: {
        platform: device.platform,
        appVersion: device.appVersion,
        deviceLabel: device.deviceLabel,
        lastSeenAt: new Date(),
        revokedAt: null,
      },
      create: {
        userId,
        clientGeneratedDeviceId: device.clientGeneratedDeviceId,
        platform: device.platform,
        appVersion: device.appVersion,
        deviceLabel: device.deviceLabel,
      },
    });

    const rawRefresh = generateOpaqueRefreshToken();
    await this.prisma.refreshSession.create({
      data: {
        userId,
        deviceId: persistedDevice.id,
        tokenHash: hashRefreshToken(rawRefresh, this.refreshPepper()),
        tokenFamilyId: randomUUID(),
        expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
      },
    });

    const tokens = this.issueAccess(userId, persistedDevice.id, rawRefresh);
    const [user, recordCount, latest] = await Promise.all([
      this.prisma.user.findUniqueOrThrow({
        where: { id: userId },
      }),
      this.prisma.syncRecord.count({
        where: { userId, deletedAt: null },
      }),
      this.prisma.syncChangeLog.findFirst({
        where: { userId },
        orderBy: { sequence: 'desc' },
        select: { sequence: true },
      }),
    ]);
    return {
      ...tokens,
      user: {
        id: user.id,
        displayName: user.displayName,
        email: user.email,
        avatarKey: user.avatarKey,
      },
      deviceId: persistedDevice.id,
      hasSynchronizedRecords: recordCount > 0,
      bootstrapEmpty: recordCount === 0,
      bootstrapRequired: recordCount > 0,
      currentCursor: latest ? latest.sequence.toString() : '0',
    };
  }

  async revokeFamilyIfReuse(presentedHash: string) {
    const session = await this.prisma.refreshSession.findFirst({
      where: { tokenHash: presentedHash },
    });
    if (!session) return;
    if (session.revokedAt) {
      await this.prisma.refreshSession.updateMany({
        where: { tokenFamilyId: session.tokenFamilyId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
  }

  private issueAccess(userId: string, deviceId: string, refreshToken: string) {
    const { token, expiresAt } = signAccessToken(
      { sub: userId, deviceId, ver: 1 },
      this.accessSecret(),
      ACCESS_TTL_SECONDS,
    );
    return {
      accessToken: token,
      accessTokenExpiresAt: expiresAt.toISOString(),
      refreshToken,
      refreshTokenExpiresAt: new Date(
        Date.now() + REFRESH_TTL_MS,
      ).toISOString(),
    };
  }

  private accessSecret(): string {
    return this.config.get('auth', { infer: true }).accessSecret;
  }

  private refreshPepper(): string {
    return this.config.get('auth', { infer: true }).refreshPepper;
  }
}
