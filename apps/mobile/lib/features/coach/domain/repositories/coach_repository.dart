import '../entities/coach_suggestion.dart';

abstract class CoachRepository {
  Future<List<CoachSuggestion>> fetchSuggestedPrompts();

  Future<CoachSuggestion?> fetchDailyRecommendation();
}
