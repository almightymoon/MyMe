import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../domain/sync_models.dart';
import '../domain/sync_outbox.dart';

class DurableSyncOutbox implements SyncOutbox {
  DurableSyncOutbox(this._db) {
    _migrate();
  }

  final Database _db;

  factory DurableSyncOutbox.openFile(String path) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    return DurableSyncOutbox(sqlite3.open(path));
  }

  factory DurableSyncOutbox.memory() {
    return DurableSyncOutbox(sqlite3.openInMemory());
  }

  static String filePathFor({
    required Directory documents,
    required String namespace,
  }) {
    return p.join(documents.path, 'sync', '$namespace.sqlite');
  }

  void _migrate() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS sync_mutations (
        mutationId TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        deviceId TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        baseServerVersion INTEGER,
        localVersion INTEGER NOT NULL,
        clientUpdatedAt TEXT NOT NULL,
        payloadJson TEXT,
        state TEXT NOT NULL,
        attemptCount INTEGER NOT NULL,
        nextAttemptAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        sanitizedErrorCode TEXT
      );
    ''');
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sync_mutations_account_state ON sync_mutations(accountId, state);',
    );
    _db.execute('''
      CREATE TABLE IF NOT EXISTS sync_cursor (
        accountId TEXT NOT NULL,
        deviceId TEXT NOT NULL,
        serverChangeSequence TEXT NOT NULL,
        lastSuccessfulSyncAt TEXT,
        PRIMARY KEY (accountId, deviceId)
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS sync_conflicts (
        conflictId TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        localPayloadJson TEXT,
        serverPayloadJson TEXT,
        localBaseVersion INTEGER,
        serverVersion INTEGER,
        status TEXT NOT NULL,
        resolution TEXT,
        detectedAt TEXT NOT NULL,
        resolvedAt TEXT
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS asset_upload_queue (
        queueId TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        localAssetId TEXT NOT NULL,
        backendAssetId TEXT,
        localRelativePath TEXT NOT NULL,
        checksum TEXT NOT NULL,
        state TEXT NOT NULL,
        attemptCount INTEGER NOT NULL,
        nextAttemptAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        sanitizedErrorCode TEXT
      );
    ''');
  }

  @override
  List<SyncMutation> pendingFor(String accountId) {
    final rows = _db.select(
      '''
      SELECT * FROM sync_mutations
      WHERE accountId = ? AND state IN ('pending', 'retryableFailure')
      ORDER BY createdAt ASC
      ''',
      [accountId],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  List<SyncMutation> allFor(String accountId) {
    final rows = _db.select(
      'SELECT * FROM sync_mutations WHERE accountId = ?',
      [accountId],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  void enqueue(SyncMutation mutation) {
    final existing = _db.select(
      '''
      SELECT * FROM sync_mutations
      WHERE accountId = ? AND entityType = ? AND entityId = ? AND state = 'pending'
      LIMIT 1
      ''',
      [mutation.accountId, mutation.entityType.name, mutation.entityId],
    );
    if (existing.isNotEmpty) {
      final previous = _fromRow(existing.first);
      if (mutation.operation == SyncOperationType.delete &&
          previous.baseServerVersion == null) {
        _db.execute('DELETE FROM sync_mutations WHERE mutationId = ?', [
          previous.mutationId,
        ]);
        if (previous.operation == SyncOperationType.create) {
          return;
        }
      } else {
        _db.execute('DELETE FROM sync_mutations WHERE mutationId = ?', [
          previous.mutationId,
        ]);
      }
      if (previous.operation == SyncOperationType.create &&
          mutation.operation == SyncOperationType.update) {
        _insert(
          SyncMutation(
            mutationId: mutation.mutationId,
            accountId: mutation.accountId,
            deviceId: mutation.deviceId,
            entityType: mutation.entityType,
            entityId: mutation.entityId,
            operation: SyncOperationType.create,
            localVersion: mutation.localVersion,
            clientUpdatedAt: mutation.clientUpdatedAt,
            createdAt: mutation.createdAt,
            attemptCount: mutation.attemptCount,
            state: mutation.state,
            payload: mutation.payload,
            baseServerVersion: mutation.baseServerVersion,
            nextAttemptAt: mutation.nextAttemptAt,
          ),
        );
        return;
      }
    }
    _insert(mutation);
  }

  void _insert(SyncMutation mutation) {
    _db.execute(
      '''
      INSERT INTO sync_mutations (
        mutationId, accountId, deviceId, entityType, entityId, operation,
        baseServerVersion, localVersion, clientUpdatedAt, payloadJson, state,
        attemptCount, nextAttemptAt, createdAt, updatedAt, sanitizedErrorCode
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        mutation.mutationId,
        mutation.accountId,
        mutation.deviceId,
        mutation.entityType.name,
        mutation.entityId,
        mutation.operation.name,
        mutation.baseServerVersion,
        mutation.localVersion,
        mutation.clientUpdatedAt.toUtc().toIso8601String(),
        mutation.payload == null ? null : jsonEncode(mutation.payload),
        mutation.state.name,
        mutation.attemptCount,
        mutation.nextAttemptAt?.toUtc().toIso8601String(),
        mutation.createdAt.toUtc().toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
        null,
      ],
    );
  }

  @override
  void markAccepted(String mutationId) {
    markState(mutationId, SyncMutationState.accepted);
  }

  @override
  void markState(String mutationId, SyncMutationState state) {
    _db.execute(
      'UPDATE sync_mutations SET state = ?, updatedAt = ? WHERE mutationId = ?',
      [state.name, DateTime.now().toUtc().toIso8601String(), mutationId],
    );
  }

  @override
  void deleteAccount(String accountId) {
    _db.execute('DELETE FROM sync_mutations WHERE accountId = ?', [accountId]);
    _db.execute('DELETE FROM sync_cursor WHERE accountId = ?', [accountId]);
    _db.execute('DELETE FROM sync_conflicts WHERE accountId = ?', [accountId]);
    _db.execute('DELETE FROM asset_upload_queue WHERE accountId = ?', [
      accountId,
    ]);
  }

  String readCursor(String accountId, String deviceId) {
    final rows = _db.select(
      'SELECT serverChangeSequence FROM sync_cursor WHERE accountId = ? AND deviceId = ?',
      [accountId, deviceId],
    );
    if (rows.isEmpty) return '0';
    return rows.first['serverChangeSequence'] as String;
  }

  void writeCursor(String accountId, String deviceId, String sequence) {
    _db.execute(
      '''
      INSERT INTO sync_cursor (accountId, deviceId, serverChangeSequence, lastSuccessfulSyncAt)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(accountId, deviceId) DO UPDATE SET
        serverChangeSequence = excluded.serverChangeSequence,
        lastSuccessfulSyncAt = excluded.lastSuccessfulSyncAt
      ''',
      [accountId, deviceId, sequence, DateTime.now().toUtc().toIso8601String()],
    );
  }

  void addConflict(
    SyncConflict conflict, {
    String? localJson,
    String? serverJson,
  }) {
    _db.execute(
      '''
      INSERT OR REPLACE INTO sync_conflicts (
        conflictId, accountId, entityType, entityId, localPayloadJson, serverPayloadJson,
        localBaseVersion, serverVersion, status, resolution, detectedAt, resolvedAt
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        conflict.id,
        '',
        conflict.entityType.name,
        conflict.entityId,
        localJson,
        serverJson,
        null,
        null,
        conflict.status,
        null,
        conflict.detectedAt.toUtc().toIso8601String(),
        null,
      ],
    );
  }

  List<SyncConflict> conflictsFor(String accountId) {
    final rows = _db.select(
      'SELECT * FROM sync_conflicts WHERE accountId = ? AND status = ?',
      [accountId, 'open'],
    );
    return rows
        .map(
          (row) => SyncConflict(
            id: row['conflictId'] as String,
            entityType: SyncEntityType.values.byName(
              row['entityType'] as String,
            ),
            entityId: row['entityId'] as String,
            detectedAt: DateTime.parse(row['detectedAt'] as String),
            status: row['status'] as String,
          ),
        )
        .toList();
  }

  void close() => _db.dispose();

  SyncMutation _fromRow(Row row) {
    final payloadRaw = row['payloadJson'] as String?;
    return SyncMutation(
      mutationId: row['mutationId'] as String,
      accountId: row['accountId'] as String,
      deviceId: row['deviceId'] as String,
      entityType: SyncEntityType.values.byName(row['entityType'] as String),
      entityId: row['entityId'] as String,
      operation: SyncOperationType.values.byName(row['operation'] as String),
      localVersion: row['localVersion'] as int,
      clientUpdatedAt: DateTime.parse(row['clientUpdatedAt'] as String),
      createdAt: DateTime.parse(row['createdAt'] as String),
      attemptCount: row['attemptCount'] as int,
      state: SyncMutationState.values.byName(row['state'] as String),
      baseServerVersion: row['baseServerVersion'] as int?,
      payload: payloadRaw == null
          ? null
          : Map<String, Object?>.from(jsonDecode(payloadRaw) as Map),
      nextAttemptAt: row['nextAttemptAt'] == null
          ? null
          : DateTime.parse(row['nextAttemptAt'] as String),
    );
  }
}
