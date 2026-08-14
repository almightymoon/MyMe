import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../data/durable_sync_outbox.dart';
import '../data/memory_sync_outbox.dart';
import '../domain/sync_mutation_journal.dart';
import '../domain/sync_outbox.dart';

final syncOutboxProvider = Provider<SyncOutbox>((ref) {
  ref.watch(authSessionProvider);
  return DurableSyncOutbox.memory();
});

final syncMutationJournalProvider = Provider<SyncMutationJournal>((ref) {
  return SyncMutationJournal(ref.watch(syncOutboxProvider));
});

/// Test helper: in-memory outbox without sqlite.
SyncOutbox memorySyncOutboxForTests() => MemorySyncOutbox();
