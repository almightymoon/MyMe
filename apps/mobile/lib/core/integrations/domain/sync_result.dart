import 'integration_error.dart';
import 'integration_provider.dart';

/// Outcome of one sync pass (connect/pull/push/full) for an integration.
///
/// Counts only — never carries the synced content itself.
class SyncResult {
  const SyncResult({
    required this.provider,
    required this.startedAt,
    required this.finishedAt,
    this.pulledCount = 0,
    this.pushedCount = 0,
    this.deletedCount = 0,
    this.conflictCount = 0,
    this.error,
  });

  final IntegrationProvider provider;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int pulledCount;
  final int pushedCount;
  final int deletedCount;
  final int conflictCount;
  final IntegrationError? error;

  bool get isSuccess => error == null;
  Duration get duration => finishedAt.difference(startedAt);
  int get totalChanges => pulledCount + pushedCount + deletedCount;

  factory SyncResult.empty(IntegrationProvider provider, DateTime at) {
    return SyncResult(provider: provider, startedAt: at, finishedAt: at);
  }

  SyncResult merge(SyncResult other) {
    assert(other.provider == provider);
    return SyncResult(
      provider: provider,
      startedAt: startedAt.isBefore(other.startedAt)
          ? startedAt
          : other.startedAt,
      finishedAt: finishedAt.isAfter(other.finishedAt)
          ? finishedAt
          : other.finishedAt,
      pulledCount: pulledCount + other.pulledCount,
      pushedCount: pushedCount + other.pushedCount,
      deletedCount: deletedCount + other.deletedCount,
      conflictCount: conflictCount + other.conflictCount,
      error: other.error ?? error,
    );
  }

  SyncResult copyWith({
    int? pulledCount,
    int? pushedCount,
    int? deletedCount,
    int? conflictCount,
    DateTime? finishedAt,
    IntegrationError? error,
  }) {
    return SyncResult(
      provider: provider,
      startedAt: startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      pulledCount: pulledCount ?? this.pulledCount,
      pushedCount: pushedCount ?? this.pushedCount,
      deletedCount: deletedCount ?? this.deletedCount,
      conflictCount: conflictCount ?? this.conflictCount,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'SyncResult(${provider.name}, pulled: $pulledCount, pushed: '
      '$pushedCount, deleted: $deletedCount, conflicts: $conflictCount, '
      'success: $isSuccess)';
}
