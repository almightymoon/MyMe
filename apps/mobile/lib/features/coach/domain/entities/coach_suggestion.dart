class CoachSuggestion {
  const CoachSuggestion({
    required this.id,
    required this.prompt,
    required this.demoResponse,
    this.isDailyRecommendation = false,
  });

  final String id;
  final String prompt;
  final String demoResponse;
  final bool isDailyRecommendation;
}
