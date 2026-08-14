import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/application/providers/core_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../onboarding/data/onboarding_preferences.dart';
import '../../user/application/providers/user_providers.dart';
import '../../user/domain/entities/profile_avatar.dart';

class EditProfileState {
  const EditProfileState({
    this.displayName = '',
    this.avatarId = ProfileAvatarCatalog.defaultId,
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final String displayName;
  final String avatarId;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  EditProfileState copyWith({
    String? displayName,
    String? avatarId,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) {
    return EditProfileState(
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class EditProfileController extends StateNotifier<EditProfileState> {
  EditProfileController(this._ref)
    : super(
        EditProfileState(
          displayName:
              OnboardingPreferences.readDisplayName(
                _ref.read(sharedPreferencesProvider),
              ) ??
              '',
          avatarId: OnboardingPreferences.readAvatarId(
            _ref.read(sharedPreferencesProvider),
          ),
        ),
      );

  final Ref _ref;

  static const int maxNameLength = 40;

  void setDisplayName(String value) =>
      state = state.copyWith(displayName: value, clearError: true);

  void setAvatarId(String value) =>
      state = state.copyWith(avatarId: value, clearError: true);

  Map<String, String> validate() {
    final errors = <String, String>{};
    final name = state.displayName.trim();
    if (name.isEmpty) {
      errors['displayName'] = 'Name is required';
    } else if (name.length > maxNameLength) {
      errors['displayName'] = 'Keep the name under $maxNameLength characters';
    }
    if (!ProfileAvatarCatalog.isValid(state.avatarId)) {
      errors['avatarId'] = 'Choose an avatar';
    }
    return errors;
  }

  Future<bool> submit() async {
    if (state.isSubmitting) return false;
    final errors = validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return false;
    }
    state = state.copyWith(
      isSubmitting: true,
      fieldErrors: const {},
      clearError: true,
    );
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      await OnboardingPreferences.writeDisplayName(prefs, state.displayName);
      await OnboardingPreferences.writeAvatarId(prefs, state.avatarId);
      notifyLocalProfileChanged(_ref);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: userFacingErrorMessage(error),
      );
      return false;
    }
  }
}

final editProfileControllerProvider =
    StateNotifierProvider.autoDispose<EditProfileController, EditProfileState>((
      ref,
    ) {
      return EditProfileController(ref);
    });
