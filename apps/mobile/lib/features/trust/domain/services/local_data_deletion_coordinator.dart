import '../entities/deletion_scope.dart';

/// Coordinates local MeMy data wipes without touching external stores.
abstract class LocalDataDeletionCoordinator {
  Future<DeletionResult> delete(Set<DeletionScope> scopes);
}
