import '../entities/deletion_scope.dart';

/// Coordinates local MeMy data wipes without touching external stores.
abstract class LocalDataDeletionCoordinator {
  static const String globalConfirmationPhrase = 'DELETE LOCAL DATA';

  /// Trimmed, case-sensitive match against [globalConfirmationPhrase].
  static bool matchesGlobalConfirmation(String? phrase) {
    if (phrase == null) return false;
    return phrase.trim() == globalConfirmationPhrase;
  }

  /// Whether plans that include a full wipe require typed confirmation.
  bool get requiresTypedConfirmation;

  Future<DeletionPlan> plan(Set<DeletionScope> scopes);

  Future<DeletionExecutionReport> execute(
    DeletionPlan plan, {
    required String? confirmationPhrase,
  });

  /// Retries only previously failed retryable steps; skips completed ones.
  Future<DeletionExecutionReport> retryFailed(
    DeletionExecutionReport previous, {
    required String? confirmationPhrase,
  });
}
