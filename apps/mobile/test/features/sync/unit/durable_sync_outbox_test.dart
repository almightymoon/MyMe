import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/sync/data/durable_sync_outbox.dart';
import 'package:memy/features/sync/domain/sync_models.dart';
import 'package:memy/features/sync/domain/sync_mutation_journal.dart';

SyncMutation mutation({
  required String id,
  required String accountId,
  required SyncOperationType operation,
}) {
  return SyncMutation(
    mutationId: id,
    accountId: accountId,
    deviceId: 'dev',
    entityType: SyncEntityType.goal,
    entityId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    operation: operation,
    localVersion: 1,
    clientUpdatedAt: DateTime.utc(2026, 8, 11),
    createdAt: DateTime.utc(2026, 8, 11),
    attemptCount: 0,
    state: SyncMutationState.pending,
    payload: const {'name': 'Save'},
  );
}

void main() {
  test(
    'durable outbox survives in-memory reopen semantics and isolates accounts',
    () {
      final outbox = DurableSyncOutbox.memory();
      outbox.enqueue(
        mutation(id: 'm1', accountId: 'a', operation: SyncOperationType.create),
      );
      outbox.enqueue(
        mutation(id: 'm2', accountId: 'b', operation: SyncOperationType.create),
      );
      expect(outbox.pendingFor('a'), hasLength(1));
      expect(outbox.pendingFor('b'), hasLength(1));
      outbox.writeCursor('a', 'dev', '42');
      expect(outbox.readCursor('a', 'dev'), '42');
      expect(outbox.readCursor('b', 'dev'), '0');
      outbox.deleteAccount('a');
      expect(outbox.pendingFor('a'), isEmpty);
      expect(outbox.pendingFor('b'), hasLength(1));
      outbox.close();
    },
  );

  test(
    'journal coalesces create then update and cancels create then delete',
    () {
      final outbox = DurableSyncOutbox.memory();
      final journal = SyncMutationJournal(outbox);
      journal.recordCreate(
        accountId: 'a',
        deviceId: 'dev',
        entityType: SyncEntityType.goal,
        entityId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        localVersion: 1,
        payload: const {'name': 'One'},
      );
      journal.recordUpdate(
        accountId: 'a',
        deviceId: 'dev',
        entityType: SyncEntityType.goal,
        entityId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        localVersion: 2,
        payload: const {'name': 'Two'},
      );
      expect(outbox.pendingFor('a'), hasLength(1));
      expect(outbox.pendingFor('a').single.payload?['name'], 'Two');
      journal.recordDelete(
        accountId: 'a',
        deviceId: 'dev',
        entityType: SyncEntityType.goal,
        entityId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        localVersion: 3,
      );
      expect(outbox.pendingFor('a'), isEmpty);
      outbox.close();
    },
  );
}
