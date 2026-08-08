import '../../domain/entities/user_profile.dart';

/// Demo seed data inspired by `/app/js/data.js`.
abstract final class UserSeed {
  static const UserProfile demoProfile = UserProfile(
    id: 'emma',
    displayName: 'Emma',
    fullName: 'Emma Chen',
    initials: 'EC',
    tagline: 'Your life, perfectly balanced.',
  );
}
