import '../../domain/entities/profile_avatar.dart';
import '../../domain/entities/user_profile.dart';

/// Demo seed data inspired by `/app/js/data.js`.
abstract final class UserSeed {
  static const UserProfile demoProfile = UserProfile(
    id: 'emma',
    displayName: 'Emma',
    fullName: 'Emma Chen',
    initials: 'EC',
    avatarId: ProfileAvatarCatalog.defaultId,
    tagline: 'Your life, perfectly balanced.',
  );
}
