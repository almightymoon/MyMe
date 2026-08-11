import '../domain/sync_models.dart';

/// Process-local outbox used by unit tests and as the in-app queue until the
/// per-account Drift database is generated. Production adapters must journal
/// into this store in the same transaction as the local record write.
class MemorySyncOutbox {
  final List<SyncMutation> _items = [];

  List<SyncMutation> get pending =>
      _items.where((item) => item.state == SyncMutationState.pending).toList();

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
}
