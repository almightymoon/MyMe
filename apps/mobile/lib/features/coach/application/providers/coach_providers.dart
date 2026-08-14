import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_coach_repository.dart';
import '../../domain/entities/coach_suggestion.dart';
import '../../domain/repositories/coach_repository.dart';
import '../services/coach_conversation_controller.dart';

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return FakeCoachRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

final coachPromptsProvider = FutureProvider.autoDispose<List<CoachSuggestion>>((
  ref,
) async {
  return ref.watch(coachRepositoryProvider).fetchSuggestedPrompts();
});

final coachConversationProvider =
    StateNotifierProvider<CoachConversationController, CoachConversationState>((
      ref,
    ) {
      return CoachConversationController();
    });
