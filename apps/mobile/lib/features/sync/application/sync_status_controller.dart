import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sync_models.dart';

class SyncStatusSnapshot {
  const SyncStatusSnapshot({
    required this.kind,
    required this.pendingCount,
    required this.conflictCount,
    this.lastSuccessfulSyncAt,
  });

  final SyncStatusKind kind;
  final int pendingCount;
  final int conflictCount;
  final DateTime? lastSuccessfulSyncAt;

  String get label {
    switch (kind) {
      case SyncStatusKind.synced:
        return 'Synced';
      case SyncStatusKind.syncing:
        return 'Syncing';
      case SyncStatusKind.offline:
        return 'Offline — changes saved on this device';
      case SyncStatusKind.pendingChanges:
        return 'Pending changes';
      case SyncStatusKind.signInRequired:
        return 'Sign in required to sync';
      case SyncStatusKind.error:
        return 'Sync error';
      case SyncStatusKind.conflict:
        return 'Conflict needs review';
    }
  }
}

final syncStatusProvider = StateProvider<SyncStatusSnapshot>((ref) {
  return const SyncStatusSnapshot(
    kind: SyncStatusKind.synced,
    pendingCount: 0,
    conflictCount: 0,
  );
});
