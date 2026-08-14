import '../../domain/entities/coach_suggestion.dart';

/// Demo seed data inspired by `/app/js/data.js` coach replies.
///
/// These are explicitly fake — no live model is contacted.
abstract final class CoachSeed {
  static const String demoResponsePrefix = 'Demo response';

  static const CoachSuggestion dailyRecommendation = CoachSuggestion(
    id: 'daily',
    prompt: 'Daily focus recommendation',
    demoResponse:
        'Block 45 minutes this afternoon for deep work on your research outline.',
    isDailyRecommendation: true,
  );

  static const List<CoachSuggestion> suggestedPrompts = [
    CoachSuggestion(
      id: 'focus',
      prompt: 'What should I focus on today?',
      demoResponse:
          "Protect your 2:00-3:30 Research Work block. You're at 55% on the paper — "
          'one solid session today keeps Dec 15 realistic.',
    ),
    CoachSuggestion(
      id: 'goals',
      prompt: 'How am I doing with my goals?',
      demoResponse:
          '3 of 4 active goals are on track. Emergency fund is leading at 43%. '
          'Research paper needs protected focus time this week.',
    ),
    CoachSuggestion(
      id: 'spend',
      prompt: 'Help me manage my spending',
      demoResponse:
          'Food is about 30% of expenses this month. Cutting two cafe visits a week '
          'could free roughly PKR 8–12K monthly.',
    ),
    CoachSuggestion(
      id: 'plan',
      prompt: 'Plan my day',
      demoResponse:
          '1) Finish AI research outline in your focus block\n'
          '2) Keep the 6:00 PM gym session\n'
          '3) Move PKR 500 toward your emergency fund',
    ),
  ];

  static String wrapDemoResponse(String body) =>
      '$demoResponsePrefix — $body\n\n(Live AI is not connected.)';
}
