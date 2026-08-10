/// Selectable wipe scopes for local MeMy-owned data.
///
/// Legacy names ([calendarCache], [healthCache]) are kept for UI continuity
/// and map to the expanded scopes during [DeletionPlan] building.
enum DeletionScope {
  goals,

  /// Explicit Goals cache clear (API mode). Same wipe path as [goals] when
  /// the repository is [ApiGoalRepository].
  goalsLocalCache,

  finance,
  habits,

  /// UI / legacy: imported cache + MeMy local records (never device gateway).
  calendarCache,

  /// Imported external event cache only (keeps MeMy-authored local events).
  calendarImportedCache,

  /// MeMy-authored local calendar records (+ typically imported cache wipe).
  calendarMeMyLocalRecords,

  /// Calendar integration / connection configuration only.
  calendarIntegrationState,

  /// Device calendar events — NEVER included in [allLocalMeMyData].
  calendarDeviceEvents,

  /// Legacy alias for [healthDerivedCache].
  healthCache,

  /// In-memory health summaries only.
  healthDerivedCache,

  healthConnectionConfiguration,
  preferences,
  allLocalMeMyData,
}

/// Planned wipe before execution — used for confirmation UI.
class DeletionPlan {
  const DeletionPlan({
    required this.requestedScopes,
    required this.steps,
    required this.requiresTypedConfirmation,
    this.whatWillBeDeleted = const [],
    this.whatWillRemain = const [],
    this.warnings = const [],
  });

  final Set<DeletionScope> requestedScopes;
  final List<DeletionStep> steps;
  final bool requiresTypedConfirmation;
  final List<String> whatWillBeDeleted;
  final List<String> whatWillRemain;
  final List<String> warnings;

  bool get isEmpty => steps.isEmpty;
}

class DeletionStep {
  const DeletionStep({
    required this.scope,
    required this.label,
    this.whatWillBeDeleted = '',
    this.whatWillRemain = '',
    this.estimatedCount,
  });

  final DeletionScope scope;
  final String label;
  final String whatWillBeDeleted;
  final String whatWillRemain;
  final int? estimatedCount;
}

enum DeletionStepStatus {
  completed,
  failed,
  skipped,
  cancelled,
  requiresUserAction,
}

enum DeletionOverallStatus {
  completed,
  completedWithIssues,
  requiresUserAction,
  failed,
  cancelled,
}

class DeletionStepResult {
  const DeletionStepResult({
    required this.scope,
    required this.status,
    this.deletedCount,
    this.userSafeMessage,
    this.retryable = false,
  });

  final DeletionScope scope;
  final DeletionStepStatus status;
  final int? deletedCount;
  final String? userSafeMessage;
  final bool retryable;
}

/// Result of [LocalDataDeletionCoordinator.execute].
class DeletionExecutionReport {
  const DeletionExecutionReport({
    required this.plan,
    required this.stepResults,
    this.warnings = const [],
    this.completedAt,
    this.cancelled = false,
  });

  final DeletionPlan plan;
  final List<DeletionStepResult> stepResults;
  final List<String> warnings;
  final DateTime? completedAt;
  final bool cancelled;

  Map<String, int> get deletedCounts {
    final map = <String, int>{};
    for (final step in stepResults) {
      if (step.status == DeletionStepStatus.completed &&
          step.deletedCount != null) {
        map[step.scope.name] = step.deletedCount!;
      }
    }
    return map;
  }

  int get totalDeleted =>
      deletedCounts.values.fold<int>(0, (sum, n) => sum + n);

  int get completedCount =>
      stepResults.where((s) => s.status == DeletionStepStatus.completed).length;

  int get failedCount =>
      stepResults.where((s) => s.status == DeletionStepStatus.failed).length;

  int get skippedCount =>
      stepResults.where((s) => s.status == DeletionStepStatus.skipped).length;

  List<DeletionScope> get retryableFailedScopes => stepResults
      .where(
        (s) =>
            s.status == DeletionStepStatus.failed &&
            s.retryable &&
            s.scope != DeletionScope.calendarDeviceEvents,
      )
      .map((s) => s.scope)
      .toList(growable: false);

  DeletionOverallStatus get overallStatus {
    if (cancelled) return DeletionOverallStatus.cancelled;
    if (stepResults.isEmpty) return DeletionOverallStatus.failed;
    final failed = failedCount;
    final needsAction = stepResults
        .where((s) => s.status == DeletionStepStatus.requiresUserAction)
        .length;
    if (needsAction > 0) return DeletionOverallStatus.requiresUserAction;
    if (failed == 0) return DeletionOverallStatus.completed;
    if (completedCount > 0) return DeletionOverallStatus.completedWithIssues;
    return DeletionOverallStatus.failed;
  }

  String get overallStatusLabel => switch (overallStatus) {
    DeletionOverallStatus.completed => 'Completed',
    DeletionOverallStatus.completedWithIssues => 'Completed with issues',
    DeletionOverallStatus.requiresUserAction =>
      'Some actions require your attention',
    DeletionOverallStatus.failed => 'Failed',
    DeletionOverallStatus.cancelled => 'Cancelled',
  };
}

/// Thrown when typed confirmation is required but missing/incorrect.
class DeletionConfirmationException implements Exception {
  const DeletionConfirmationException([
    this.message =
        'Type DELETE LOCAL DATA exactly to confirm wiping all local MeMy data.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a second [execute] starts while another is in flight.
class DeletionInFlightException implements Exception {
  const DeletionInFlightException([
    this.message = 'A local data deletion is already in progress.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Legacy result shape kept for older call sites / tests.
@Deprecated('Use DeletionExecutionReport')
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

  factory DeletionResult.fromReport(DeletionExecutionReport report) {
    return DeletionResult(
      scopes: report.plan.steps.map((s) => s.scope).toList(growable: false),
      deletedCounts: report.deletedCounts,
      warnings: report.warnings,
      completedAt: report.completedAt,
    );
  }
}
