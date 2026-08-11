class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.fullName,
    required this.initials,
    this.avatarId,
    this.tagline,
    this.email,
  });

  final String id;
  final String displayName;
  final String fullName;
  final String initials;
  final String? avatarId;
  final String? tagline;
  final String? email;

  static const empty = UserProfile(
    id: 'anonymous',
    displayName: 'Friend',
    fullName: 'Guest',
    initials: '?',
    avatarId: null,
    tagline: null,
    email: null,
  );
}
