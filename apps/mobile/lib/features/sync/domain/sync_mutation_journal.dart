import 'package:uuid/uuid.dart';

import 'sync_models.dart';
import 'sync_outbox.dart';

class SyncMutationJournal {
  SyncMutationJournal(this._outbox, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final SyncOutbox _outbox;
  final Uuid _uuid;

  void recordCreate({
    required String accountId,
    required String deviceId,
    required SyncEntityType entityType,
    required String entityId,
    required int localVersion,
    required Map<String, Object?> payload,
    int? baseServerVersion,
  }) {
    _enqueue(
      accountId: accountId,
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: SyncOperationType.create,
      localVersion: localVersion,
      payload: payload,
      baseServerVersion: baseServerVersion,
    );
  }

  void recordUpdate({
    required String accountId,
    required String deviceId,
    required SyncEntityType entityType,
    required String entityId,
    required int localVersion,
    required Map<String, Object?> payload,
    int? baseServerVersion,
  }) {
    _enqueue(
      accountId: accountId,
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: SyncOperationType.update,
      localVersion: localVersion,
      payload: payload,
      baseServerVersion: baseServerVersion,
    );
  }

  void recordDelete({
    required String accountId,
    required String deviceId,
    required SyncEntityType entityType,
    required String entityId,
    required int localVersion,
    int? baseServerVersion,
  }) {
    _enqueue(
      accountId: accountId,
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operation: SyncOperationType.delete,
      localVersion: localVersion,
      payload: null,
      baseServerVersion: baseServerVersion,
    );
  }

  void _enqueue({
    required String accountId,
    required String deviceId,
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operation,
    required int localVersion,
    required Map<String, Object?>? payload,
    int? baseServerVersion,
  }) {
    if (accountId.isEmpty) return;
    _outbox.enqueue(
      SyncMutation(
        mutationId: _uuid.v4(),
        accountId: accountId,
        deviceId: deviceId,
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        localVersion: localVersion,
        clientUpdatedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        attemptCount: 0,
        state: SyncMutationState.pending,
        payload: payload,
        baseServerVersion: baseServerVersion,
      ),
    );
  }
}
