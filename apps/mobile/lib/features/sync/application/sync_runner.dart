import '../../../core/network/api_client.dart';
import '../../auth/domain/secure_session_store.dart';
import '../data/durable_sync_outbox.dart';
import '../domain/sync_entity_adapter.dart';
import '../domain/sync_models.dart';
import '../domain/sync_outbox.dart';

class SyncRunner {
  SyncRunner({
    required this.client,
    required this.outbox,
    required this.adapters,
  });

  final ApiClient client;
  final SyncOutbox outbox;
  final Map<SyncEntityType, SyncEntityAdapter> adapters;
  bool _locked = false;

  Future<void> run(StoredAuthSession session) async {
    if (_locked) return;
    _locked = true;
    try {
      final pending = outbox.pendingFor(session.userId);
      if (pending.isNotEmpty) {
        final response = await client.post<Map<String, dynamic>>(
          '/sync/push',
          data: {
            'clientGeneratedDeviceId': session.clientGeneratedDeviceId,
            'mutations': [
              for (final item in pending.take(50))
                {
                  'mutationId': item.mutationId,
                  'entityType': item.entityType.name,
                  'entityId': item.entityId,
                  'operation': item.operation.name,
                  'baseServerVersion': item.baseServerVersion,
                  'clientUpdatedAt': item.clientUpdatedAt
                      .toUtc()
                      .toIso8601String(),
                  'payload': item.payload,
                },
            ],
          },
        );
        final accepted = response.data?['accepted'];
        if (accepted is List) {
          for (final row in accepted) {
            if (row is Map && row['mutationId'] != null) {
              outbox.markAccepted(row['mutationId'].toString());
            }
          }
        }
        final conflicts = response.data?['conflicts'];
        if (conflicts is List && outbox is DurableSyncOutbox) {
          for (final row in conflicts) {
            if (row is! Map) continue;
            (outbox as DurableSyncOutbox).addConflict(
              SyncConflict(
                id: row['mutationId'].toString(),
                entityType: SyncEntityType.values.byName(
                  row['entityType'].toString(),
                ),
                entityId: row['entityId'].toString(),
                detectedAt: DateTime.now().toUtc(),
                status: 'open',
              ),
            );
          }
        }
      }

      var cursor = outbox is DurableSyncOutbox
          ? (outbox as DurableSyncOutbox).readCursor(
              session.userId,
              session.deviceId,
            )
          : '0';
      var hasMore = true;
      while (hasMore) {
        final pulled = await client.get<Map<String, dynamic>>(
          '/sync/pull',
          queryParameters: {'cursor': cursor, 'limit': 100},
        );
        final changes = pulled.data?['changes'];
        if (changes is List) {
          for (final row in changes) {
            if (row is! Map) continue;
            final typeName = row['entityType']?.toString();
            final type = SyncEntityType.values.where((e) => e.name == typeName);
            if (type.isEmpty) continue;
            final adapter = adapters[type.first];
            if (adapter == null) continue;
            final entityId = row['entityId'].toString();
            final operation = row['operation']?.toString();
            final payload = row['payload'] is Map
                ? Map<String, Object?>.from(row['payload'] as Map)
                : <String, Object?>{};
            if (operation == 'delete') {
              await adapter.applyRemoteDelete(entityId);
            } else if (operation == 'create') {
              await adapter.applyRemoteCreate(entityId, payload);
            } else {
              await adapter.applyRemoteUpdate(entityId, payload);
            }
          }
        }
        cursor = '${pulled.data?['cursor'] ?? cursor}';
        hasMore = pulled.data?['hasMore'] == true;
        if (outbox is DurableSyncOutbox) {
          (outbox as DurableSyncOutbox).writeCursor(
            session.userId,
            session.deviceId,
            cursor,
          );
        }
        if (!hasMore) break;
      }
    } finally {
      _locked = false;
    }
  }
}
