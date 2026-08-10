import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/application/providers/core_providers.dart';
import '../data/onboarding_preferences.dart';

/// Whether local first-run setup has been finished on this device.
///
/// Kept as a notifier (rather than a plain read) so Settings' "Reset
/// onboarding" and the Finish step both push the router to re-evaluate.
class OnboardingCompletionNotifier extends StateNotifier<bool> {
  OnboardingCompletionNotifier(this._ref)
    : super(
        OnboardingPreferences.isComplete(_ref.read(sharedPreferencesProvider)),
      );

  final Ref _ref;

  /// Returns false when setup was already complete (double-finish guard).
  Future<bool> markComplete() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final changed = await OnboardingPreferences.markComplete(prefs);
    state = true;
    return changed;
  }

  /// Clears the completion flag only. User data is untouched.
  Future<void> reset() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await OnboardingPreferences.resetCompletion(prefs);
    state = false;
  }
}

final onboardingCompletionProvider =
    StateNotifierProvider<OnboardingCompletionNotifier, bool>((ref) {
      return OnboardingCompletionNotifier(ref);
    });
