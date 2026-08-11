import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/release_capabilities.dart';
import '../../../../core/data/fake_repository_config.dart';
import '../../../onboarding/data/onboarding_preferences.dart';
import '../../data/repositories/fake_user_repository.dart';
import '../../data/repositories/local_user_repository.dart';
import '../../data/seed/user_seed.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final capabilities = ref.watch(releaseCapabilitiesProvider);
  if (capabilities.demoAuth) {
    return FakeUserRepository(config: ref.watch(fakeRepositoryConfigProvider));
  }
  return LocalUserRepository(prefs: ref.watch(sharedPreferencesProvider));
});

/// Bumped after local profile fields are written so chrome re-reads prefs.
final profileTickProvider = StateProvider<int>((ref) => 0);

void notifyLocalProfileChanged(Ref ref) {
  ref.read(profileTickProvider.notifier).state++;
}

/// Preferred greeting / profile name for local-first builds.
final displayNameProvider = Provider<String>((ref) {
  ref.watch(profileTickProvider);
  final capabilities = ref.watch(releaseCapabilitiesProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final fromPrefs = OnboardingPreferences.readDisplayName(prefs);
  if (fromPrefs != null) return fromPrefs;
  if (capabilities.demoAuth) {
    return UserSeed.demoProfile.displayName;
  }
  return 'there';
});

final selectedAvatarIdProvider = Provider<String>((ref) {
  ref.watch(profileTickProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingPreferences.readAvatarId(prefs);
});

final userProfileProvider = FutureProvider.autoDispose<UserProfile>((
  ref,
) async {
  ref.watch(profileTickProvider);
  return ref.watch(userRepositoryProvider).fetchProfile();
});
