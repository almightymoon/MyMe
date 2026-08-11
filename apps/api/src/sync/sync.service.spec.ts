import { SyncService } from './sync.service';

describe('SyncService ownership', () => {
  const records: Array<Record<string, unknown>> = [];
  const receipts: Array<Record<string, unknown>> = [];
  const changes: Array<Record<string, unknown>> = [];
  const devices = [
    {
      id: '11111111-1111-4111-8111-111111111111',
      userId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      clientGeneratedDeviceId: 'device-client-aaaaaaaa',
      revokedAt: null,
    },
  ];
  let sequence = 1;

  const prisma: any = {
    device: {
      findFirst: jest.fn(
        async ({ where }: { where: Record<string, unknown> }) => {
          return (
            devices.find(
              (row) =>
                row.userId === where.userId &&
                row.clientGeneratedDeviceId === where.clientGeneratedDeviceId &&
                row.revokedAt == null,
            ) ?? null
          );
        },
      ),
    },
    syncRecord: {
      findUnique: jest.fn(
        async ({
          where,
        }: {
          where: {
            userId_entityType_entityId: {
              userId: string;
              entityType: string;
              entityId: string;
            };
          };
        }) => {
          return (
            records.find(
              (row) =>
                row.userId === where.userId_entityType_entityId.userId &&
                row.entityType ===
                  where.userId_entityType_entityId.entityType &&
                row.entityId === where.userId_entityType_entityId.entityId,
            ) ?? null
          );
        },
      ),
      findMany: jest.fn(
        async ({
          where,
          take,
        }: {
          where: {
            userId: string;
            OR?: Array<Record<string, unknown>>;
          };
          take?: number;
        }) => {
          let rows = records.filter(
            (row) => row.userId === where.userId && !row.deletedAt,
          );
          const or = where.OR;
          if (or && or.length === 2) {
            const gtType = (or[0] as { entityType: { gt: string } }).entityType
              .gt;
            const same = or[1] as {
              entityType: string;
              entityId: { gt: string };
            };
            rows = rows.filter(
              (row) =>
                String(row.entityType) > gtType ||
                (row.entityType === same.entityType &&
                  String(row.entityId) > same.entityId.gt),
            );
          }
          rows.sort((a, b) => {
            const type = String(a.entityType).localeCompare(
              String(b.entityType),
            );
            return type !== 0
              ? type
              : String(a.entityId).localeCompare(String(b.entityId));
          });
          return typeof take === 'number' ? rows.slice(0, take) : rows;
        },
      ),
      upsert: jest.fn(
        async ({ create }: { create: Record<string, unknown> }) => {
          records.push(create);
          return create;
        },
      ),
    },
    syncMutationReceipt: {
      findUnique: jest.fn(
        async ({
          where,
        }: {
          where: { userId_mutationId: { userId: string; mutationId: string } };
        }) => {
          return (
            receipts.find(
              (row) =>
                row.userId === where.userId_mutationId.userId &&
                row.mutationId === where.userId_mutationId.mutationId,
            ) ?? null
          );
        },
      ),
      create: jest.fn(async ({ data }: { data: Record<string, unknown> }) => {
        receipts.push(data);
        return data;
      }),
    },
    syncChangeLog: {
      create: jest.fn(async ({ data }: { data: Record<string, unknown> }) => {
        const row = { sequence: BigInt(sequence++), ...data };
        changes.push(row);
        return row;
      }),
      findMany: jest.fn(
        async ({
          where,
        }: {
          where: { userId: string; sequence: { gt: bigint } };
        }) =>
          changes.filter(
            (row) =>
              row.userId === where.userId &&
              (row.sequence as bigint) > where.sequence.gt,
          ),
      ),
      findFirst: jest.fn(async ({ where }: { where: { userId: string } }) => {
        const owned = changes.filter((row) => row.userId === where.userId);
        return owned[owned.length - 1] ?? null;
      }),
    },
    $transaction: jest.fn(async (fn: (tx: any) => Promise<unknown>) =>
      fn(prisma),
    ),
  };

  const service = new SyncService(prisma as never);
  const userA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const userB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  const entityId = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';

  beforeEach(() => {
    records.splice(0, records.length);
    receipts.splice(0, receipts.length);
    changes.splice(0, changes.length);
    sequence = 1;
  });

  it('accepts a goal create and is idempotent on replay', async () => {
    const mutation = {
      mutationId: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
      entityType: 'goal',
      entityId,
      operation: 'create',
      clientUpdatedAt: new Date().toISOString(),
      payload: { name: 'Save' },
    };
    const first = await service.push(userA, {
      clientGeneratedDeviceId: 'device-client-aaaaaaaa',
      mutations: [mutation],
    });
    const replay = await service.push(userA, {
      clientGeneratedDeviceId: 'device-client-aaaaaaaa',
      mutations: [mutation],
    });
    expect(first.accepted).toHaveLength(1);
    expect(replay.accepted[0].serverVersion).toBe(
      first.accepted[0].serverVersion,
    );
    expect(records).toHaveLength(1);
  });

  it('does not let user B use user A device id', async () => {
    await expect(
      service.push(userB, {
        clientGeneratedDeviceId: 'device-client-aaaaaaaa',
        mutations: [],
      }),
    ).rejects.toThrow();
  });

  it('rejects health entities', async () => {
    const result = await service.push(userA, {
      clientGeneratedDeviceId: 'device-client-aaaaaaaa',
      mutations: [
        {
          mutationId: 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
          entityType: 'health',
          entityId,
          operation: 'create',
          clientUpdatedAt: new Date().toISOString(),
          payload: { heartRate: 72 },
        },
      ],
    });
    expect(result.failures[0].code).toBe('SYNC_ENTITY_FORBIDDEN');
  });

  it('does not return another user cursor records on pull', async () => {
    await service.push(userA, {
      clientGeneratedDeviceId: 'device-client-aaaaaaaa',
      mutations: [
        {
          mutationId: 'ffffffff-ffff-4fff-8fff-ffffffffffff',
          entityType: 'goal',
          entityId,
          operation: 'create',
          clientUpdatedAt: new Date().toISOString(),
          payload: { name: 'Save' },
        },
      ],
    });
    const pulled = await service.pull(userB, '0', 50);
    expect(pulled.changes).toHaveLength(0);
    expect(typeof pulled.cursor).toBe('string');
  });

  it('paginates bootstrap with a composite cursor across entity types', async () => {
    records.push(
      {
        userId: userA,
        entityType: 'financeTransaction',
        entityId: '11111111-1111-4111-8111-111111111111',
        serverVersion: 1,
        payload: { name: 'A' },
        updatedAt: new Date(),
        deletedAt: null,
      },
      {
        userId: userA,
        entityType: 'goal',
        entityId: '22222222-2222-4222-8222-222222222222',
        serverVersion: 1,
        payload: { name: 'B' },
        updatedAt: new Date(),
        deletedAt: null,
      },
    );
    const first = await service.bootstrap(userA, 1);
    expect(first.records).toHaveLength(1);
    expect(first.hasMore).toBe(true);
    expect(first.nextCursor).toBeTruthy();
    const second = await service.bootstrap(
      userA,
      1,
      first.nextCursor ?? undefined,
    );
    expect(second.records).toHaveLength(1);
    expect(second.records[0].entityId).not.toEqual(first.records[0].entityId);
  });
});
