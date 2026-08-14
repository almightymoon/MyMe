import '../domain/sync_models.dart';
import '../domain/sync_outbox.dart';

/// Process-local outbox used by unit tests. Production uses [DurableSyncOutbox].
class MemorySyncOutbox implements SyncOutbox {
  final List<SyncMutation> _items = [];

  List<SyncMutation> get pending => pendingFor('');

  @override
  List<SyncMutation> pendingFor(String accountId) {
    return _items
        .where(
          (item) =>
              item.state == SyncMutationState.pending &&
              (accountId.isEmpty || item.accountId == accountId),
        )
        .toList();
  }

  @override
  List<SyncMutation> allFor(String accountId) {
    return _items.where((item) => item.accountId == accountId).toList();
  }

  @override
  void enqueue(SyncMutation mutation) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.accountId == mutation.accountId &&
          item.entityType == mutation.entityType &&
          item.entityId == mutation.entityId &&
          item.state == SyncMutationState.pending,
    );
    if (existingIndex >= 0) {
      final previous = _items[existingIndex];
      if (previous.operation == SyncOperationType.create &&
          mutation.operation == SyncOperationType.delete) {
        _items.removeAt(existingIndex);
        return;
      }
      _items[existingIndex] = mutation;
      return;
    }
    _items.add(mutation);
  }

  @override
  void markAccepted(String mutationId) {
    final index = _items.indexWhere((item) => item.mutationId == mutationId);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = SyncMutation(
      mutationId: current.mutationId,
      accountId: current.accountId,
      deviceId: current.deviceId,
      entityType: current.entityType,
      entityId: current.entityId,
      operation: current.operation,
      localVersion: current.localVersion,
      clientUpdatedAt: current.clientUpdatedAt,
      createdAt: current.createdAt,
      attemptCount: current.attemptCount,
      state: SyncMutationState.accepted,
      baseServerVersion: current.baseServerVersion,
      payload: current.payload,
      nextAttemptAt: current.nextAttemptAt,
    );
  }

  @override
  void markState(String mutationId, SyncMutationState state) {
    final index = _items.indexWhere((item) => item.mutationId == mutationId);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = SyncMutation(
      mutationId: current.mutationId,
      accountId: current.accountId,
      deviceId: current.deviceId,
      entityType: current.entityType,
      entityId: current.entityId,
      operation: current.operation,
      localVersion: current.localVersion,
      clientUpdatedAt: current.clientUpdatedAt,
      createdAt: current.createdAt,
      attemptCount: current.attemptCount,
      state: state,
      baseServerVersion: current.baseServerVersion,
      payload: current.payload,
      nextAttemptAt: current.nextAttemptAt,
    );
  }

  @override
  void deleteAccount(String accountId) {
    _items.removeWhere((item) => item.accountId == accountId);
  }
}
