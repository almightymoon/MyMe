import 'sync_models.dart';

abstract interface class SyncEntityAdapter {
  SyncEntityType get entityType;

  Map<String, Object?> serializeLocalEntity(String entityId);

  void validateIncomingPayload(Map<String, Object?> payload);

  Future<void> applyRemoteCreate(String entityId, Map<String, Object?> payload);

  Future<void> applyRemoteUpdate(String entityId, Map<String, Object?> payload);

  Future<void> applyRemoteDelete(String entityId);

  Future<Map<String, Object?>?> readLocalEntity(String entityId);

  String buildConflictLabel(String entityId);

  Map<String, Object?> redactForDiagnostics(Map<String, Object?> payload);
}

class RejectingHealthAdapter implements SyncEntityAdapter {
  @override
  SyncEntityType get entityType => SyncEntityType.profile;

  @override
  Map<String, Object?> serializeLocalEntity(String entityId) => const {};

  @override
  void validateIncomingPayload(Map<String, Object?> payload) {}

  @override
  Future<void> applyRemoteCreate(
    String entityId,
    Map<String, Object?> payload,
  ) async {}

  @override
  Future<void> applyRemoteUpdate(
    String entityId,
    Map<String, Object?> payload,
  ) async {}

  @override
  Future<void> applyRemoteDelete(String entityId) async {}

  @override
  Future<Map<String, Object?>?> readLocalEntity(String entityId) async => null;

  @override
  String buildConflictLabel(String entityId) => 'Record';

  @override
  Map<String, Object?> redactForDiagnostics(Map<String, Object?> payload) {
    return {'keys': payload.keys.toList()};
  }
}
