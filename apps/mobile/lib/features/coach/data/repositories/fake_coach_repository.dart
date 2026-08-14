import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/coach_suggestion.dart';
import '../../domain/repositories/coach_repository.dart';
import '../seed/coach_seed.dart';

/// In-memory [CoachRepository] for UI development and tests.
///
/// Demo only — does not contact a live AI model.
class FakeCoachRepository implements CoachRepository {
  FakeCoachRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<List<CoachSuggestion>> fetchSuggestedPrompts() {
    return runFakeFetch(
      config: config,
      onData: () =>
          List<CoachSuggestion>.unmodifiable(CoachSeed.suggestedPrompts),
      onEmpty: () => const <CoachSuggestion>[],
    );
  }

  @override
  Future<CoachSuggestion?> fetchDailyRecommendation() {
    return runFakeFetch(
      config: config,
      onData: () => CoachSeed.dailyRecommendation,
      onEmpty: () => null,
    );
  }
}
