import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/seed/coach_seed.dart';
import '../../domain/entities/coach_suggestion.dart';

class CoachMessage {
  const CoachMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isDemoResponse = false,
  });

  final String id;
  final String text;
  final bool isUser;
  final bool isDemoResponse;
}

class CoachConversationState {
  const CoachConversationState({this.messages = const []});

  final List<CoachMessage> messages;

  CoachConversationState copyWith({List<CoachMessage>? messages}) {
    return CoachConversationState(messages: messages ?? this.messages);
  }
}

/// Local demo conversation controller — never contacts a live model.
class CoachConversationController
    extends StateNotifier<CoachConversationState> {
  CoachConversationController() : super(const CoachConversationState());

  int _seq = 0;

  void sendPrompt(CoachSuggestion suggestion) {
    _appendExchange(
      userText: suggestion.prompt,
      demoBody: suggestion.demoResponse,
    );
  }

  void sendUserMessage(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    _appendExchange(
      userText: text,
      demoBody:
          'Thanks for the note. In a future build, MeMy Coach will reply with '
          'personalized guidance. For now this is a local demo only.',
    );
  }

  void clear() {
    state = const CoachConversationState();
  }

  void _appendExchange({required String userText, required String demoBody}) {
    final userId = 'u-${_seq++}';
    final demoId = 'd-${_seq++}';
    state = state.copyWith(
      messages: [
        ...state.messages,
        CoachMessage(id: userId, text: userText, isUser: true),
        CoachMessage(
          id: demoId,
          text: CoachSeed.wrapDemoResponse(demoBody),
          isUser: false,
          isDemoResponse: true,
        ),
      ],
    );
  }
}
