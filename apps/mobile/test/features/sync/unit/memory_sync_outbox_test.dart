import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/sync/data/memory_sync_outbox.dart';
import 'package:memy/features/sync/domain/sync_models.dart';

SyncMutation mutation({
  required String id,
  required SyncOperationType operation,
  SyncMutationState state = SyncMutationState.pending,
}) {
  return SyncMutation(
    mutationId: id,
    accountId: 'acct',
    deviceId: 'dev',
    entityType: SyncEntityType.goal,
    entityId: 'goal-1',
    operation: operation,
    localVersion: 1,
    clientUpdatedAt: DateTime.utc(2026, 8, 11),
    createdAt: DateTime.utc(2026, 8, 11),
    attemptCount: 0,
    state: state,
  );
}

void main() {
  test('create then update coalesces to one pending mutation', () {
    final outbox = MemorySyncOutbox();
    outbox.enqueue(mutation(id: 'm1', operation: SyncOperationType.create));
    outbox.enqueue(mutation(id: 'm2', operation: SyncOperationType.update));
    expect(outbox.pending, hasLength(1));
    expect(outbox.pending.single.mutationId, 'm2');
  });

  test('create then delete cancels locally', () {
    final outbox = MemorySyncOutbox();
    outbox.enqueue(mutation(id: 'm1', operation: SyncOperationType.create));
    outbox.enqueue(mutation(id: 'm2', operation: SyncOperationType.delete));
    expect(outbox.pending, isEmpty);
  });
}
