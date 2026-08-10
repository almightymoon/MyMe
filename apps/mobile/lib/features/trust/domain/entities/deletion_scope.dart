/// Selectable wipe scopes for local MeMy-owned data.
enum DeletionScope {
  goals,
  finance,
  habits,
  calendarCache,
  healthCache,
  healthConnectionConfiguration,
  preferences,
  allLocalMeMyData,
}

class DeletionResult {
  const DeletionResult({
    required this.scopes,
    required this.deletedCounts,
    this.warnings = const [],
    this.completedAt,
  });

  final List<DeletionScope> scopes;
  final Map<String, int> deletedCounts;
  final List<String> warnings;
  final DateTime? completedAt;

  int get totalDeleted =>
      deletedCounts.values.fold<int>(0, (sum, n) => sum + n);
}
