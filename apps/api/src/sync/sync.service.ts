import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { SyncMutationDto, SyncPushDto } from './dto/sync.dto';
import {
  assertEntityId,
  assertEntityType,
  assertOperation,
  validatePayload,
} from './sync-payload.validator';

const DEFAULT_LIMIT = 100;

@Injectable()
export class SyncService {
  constructor(private readonly prisma: PrismaService) {}

  async assertDevice(userId: string, clientGeneratedDeviceId: string) {
    const device = await this.prisma.device.findFirst({
      where: { userId, clientGeneratedDeviceId, revokedAt: null },
    });
    if (!device) {
      throw new ForbiddenException({
        code: 'DEVICE_NOT_OWNED',
        message: 'This device is not registered to the account.',
      });
    }
    return device;
  }

  async bootstrap(userId: string, limit = DEFAULT_LIMIT, afterCursor?: string) {
    const after = decodeBootstrapCursor(afterCursor);
    const [records, cursor] = await Promise.all([
      this.prisma.syncRecord.findMany({
        where: {
          userId,
          deletedAt: null,
          ...(after
            ? {
                OR: [
                  { entityType: { gt: after.entityType } },
                  {
                    entityType: after.entityType,
                    entityId: { gt: after.entityId },
                  },
                ],
              }
            : {}),
        },
        orderBy: [{ entityType: 'asc' }, { entityId: 'asc' }],
        take: limit + 1,
        select: {
          entityType: true,
          entityId: true,
          serverVersion: true,
          payload: true,
          updatedAt: true,
        },
      }),
      this.currentCursor(userId),
    ]);
    const hasMore = records.length > limit;
    const page = hasMore ? records.slice(0, limit) : records;
    const last = page[page.length - 1];
    return {
      records: page.map((row) => ({
        entityType: row.entityType,
        entityId: row.entityId,
        serverVersion: row.serverVersion,
        payload: row.payload,
        updatedAt: row.updatedAt.toISOString(),
      })),
      cursor,
      nextCursor:
        hasMore && last
          ? encodeBootstrapCursor(last.entityType, last.entityId)
          : null,
      hasMore,
    };
  }

  async push(userId: string, body: SyncPushDto) {
    const device = await this.assertDevice(
      userId,
      body.clientGeneratedDeviceId,
    );
    const accepted: Array<{
      mutationId: string;
      serverVersion: number;
      entityType: string;
      entityId: string;
    }> = [];
    const conflicts: Array<{
      mutationId: string;
      entityType: string;
      entityId: string;
      serverVersion: number;
      serverPayload: unknown;
    }> = [];
    const failures: Array<{
      mutationId: string;
      code: string;
      message: string;
    }> = [];

    for (const mutation of body.mutations) {
      try {
        const result = await this.applyMutation(userId, device.id, mutation);
        if (result.kind === 'accepted') {
          accepted.push({
            mutationId: mutation.mutationId,
            serverVersion: result.serverVersion,
            entityType: mutation.entityType,
            entityId: mutation.entityId,
          });
        } else {
          conflicts.push({
            mutationId: mutation.mutationId,
            entityType: mutation.entityType,
            entityId: mutation.entityId,
            serverVersion: result.serverVersion,
            serverPayload: result.payload,
          });
        }
      } catch (error) {
        const message =
          error instanceof BadRequestException
            ? String(
                (error.getResponse() as { message?: string }).message ??
                  'Validation failed',
              )
            : 'Unable to apply this change.';
        const code =
          error instanceof BadRequestException
            ? String(
                (error.getResponse() as { code?: string }).code ??
                  'SYNC_VALIDATION',
              )
            : 'SYNC_VALIDATION';
        failures.push({
          mutationId: mutation.mutationId,
          code,
          message,
        });
      }
    }

    return {
      accepted,
      conflicts,
      failures,
      cursor: await this.currentCursor(userId),
    };
  }

  async pull(userId: string, cursor = '0', limit = DEFAULT_LIMIT) {
    const after = parseCursor(cursor);
    const changes = await this.prisma.syncChangeLog.findMany({
      where: {
        userId,
        sequence: { gt: after },
      },
      orderBy: { sequence: 'asc' },
      take: limit + 1,
    });
    const hasMore = changes.length > limit;
    const page = hasMore ? changes.slice(0, limit) : changes;
    const nextCursor =
      page.length === 0
        ? stringifyCursor(after)
        : page[page.length - 1].sequence.toString();
    return {
      changes: page.map((row) => ({
        serverChangeSequence: row.sequence.toString(),
        entityType: row.entityType,
        entityId: row.entityId,
        operation: row.operation,
        serverVersion: row.serverVersion,
        serverUpdatedAt: row.changedAt.toISOString(),
        payload: row.payload,
      })),
      cursor: nextCursor,
      hasMore,
    };
  }

  private async applyMutation(
    userId: string,
    deviceId: string,
    mutation: SyncMutationDto,
  ): Promise<
    | { kind: 'accepted'; serverVersion: number }
    | { kind: 'conflict'; serverVersion: number; payload: unknown }
  > {
    const entityType = assertEntityType(mutation.entityType);
    const operation = assertOperation(mutation.operation);
    assertEntityId(mutation.entityId);
    const payload = validatePayload(entityType, operation, mutation.payload);

    return this.prisma.$transaction(async (tx) => {
      const existingReceipt = await tx.syncMutationReceipt.findUnique({
        where: {
          userId_mutationId: {
            userId,
            mutationId: mutation.mutationId,
          },
        },
      });
      if (existingReceipt) {
        return {
          kind: 'accepted' as const,
          serverVersion: existingReceipt.serverVersion ?? 0,
        };
      }

      const current = await tx.syncRecord.findUnique({
        where: {
          userId_entityType_entityId: {
            userId,
            entityType,
            entityId: mutation.entityId,
          },
        },
      });

      if (
        current &&
        mutation.baseServerVersion != null &&
        current.serverVersion !== mutation.baseServerVersion
      ) {
        return {
          kind: 'conflict' as const,
          serverVersion: current.serverVersion,
          payload: current.payload,
        };
      }

      if (
        operation === 'delete' &&
        current &&
        mutation.baseServerVersion == null
      ) {
        return {
          kind: 'conflict' as const,
          serverVersion: current.serverVersion,
          payload: current.payload,
        };
      }

      const nextVersion = (current?.serverVersion ?? 0) + 1;
      const deletedAt = operation === 'delete' ? new Date() : null;
      const storedPayload =
        (payload as Prisma.InputJsonValue | null) ??
        (current?.payload as Prisma.InputJsonValue) ??
        {};

      await Promise.all([
        tx.syncRecord.upsert({
          where: {
            userId_entityType_entityId: {
              userId,
              entityType,
              entityId: mutation.entityId,
            },
          },
          create: {
            userId,
            entityType,
            entityId: mutation.entityId,
            serverVersion: nextVersion,
            payload: storedPayload,
            deletedAt,
            lastMutationId: mutation.mutationId,
            lastDeviceId: deviceId,
          },
          update: {
            serverVersion: nextVersion,
            payload: storedPayload,
            deletedAt,
            lastMutationId: mutation.mutationId,
            lastDeviceId: deviceId,
          },
        }),
        tx.syncChangeLog.create({
          data: {
            userId,
            entityType,
            entityId: mutation.entityId,
            operation,
            serverVersion: nextVersion,
            payload: storedPayload,
          },
        }),
        tx.syncMutationReceipt.create({
          data: {
            userId,
            mutationId: mutation.mutationId,
            result: 'accepted',
            serverVersion: nextVersion,
          },
        }),
      ]);

      return { kind: 'accepted' as const, serverVersion: nextVersion };
    });
  }

  private async currentCursor(userId: string): Promise<string> {
    const latest = await this.prisma.syncChangeLog.findFirst({
      where: { userId },
      orderBy: { sequence: 'desc' },
      select: { sequence: true },
    });
    return latest ? latest.sequence.toString() : '0';
  }
}

function parseCursor(cursor: string | number | undefined): bigint {
  try {
    return BigInt(String(cursor ?? '0'));
  } catch {
    return 0n;
  }
}

function stringifyCursor(value: bigint): string {
  return value.toString();
}

function encodeBootstrapCursor(entityType: string, entityId: string): string {
  return Buffer.from(JSON.stringify({ t: entityType, i: entityId })).toString(
    'base64url',
  );
}

function decodeBootstrapCursor(
  cursor?: string,
): { entityType: string; entityId: string } | null {
  if (!cursor) return null;
  try {
    const parsed = JSON.parse(
      Buffer.from(cursor, 'base64url').toString('utf8'),
    ) as { t?: string; i?: string };
    if (!parsed.t || !parsed.i) return null;
    return { entityType: parsed.t, entityId: parsed.i };
  } catch {
    return null;
  }
}
