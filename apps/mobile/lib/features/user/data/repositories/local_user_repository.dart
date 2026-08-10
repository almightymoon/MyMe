import 'package:shared_preferences/shared_preferences.dart';

import '../../../onboarding/data/onboarding_preferences.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

/// Device-local profile derived from onboarding preferences.
///
/// Production never invents an email, cloud account, or demo display name.
class LocalUserRepository implements UserRepository {
  LocalUserRepository({required this.prefs});

  final SharedPreferences prefs;

  @override
  Future<UserProfile> fetchProfile() async {
    final name = OnboardingPreferences.readDisplayName(prefs);
    if (name == null) {
      return UserProfile.empty;
    }
    return UserProfile(
      id: 'local',
      displayName: name,
      fullName: name,
      initials: _initialsFor(name),
      tagline: null,
      email: null,
    );
  }

  static String _initialsFor(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length == 1
          ? word.toUpperCase()
          : word.substring(0, 2).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }
}
