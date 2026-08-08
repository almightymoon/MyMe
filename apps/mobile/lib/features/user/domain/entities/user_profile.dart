class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.fullName,
    required this.initials,
    this.tagline,
  });

  final String id;
  final String displayName;
  final String fullName;
  final String initials;
  final String? tagline;

  static const empty = UserProfile(
    id: 'anonymous',
    displayName: 'Friend',
    fullName: 'Guest',
    initials: '?',
    tagline: null,
  );
}
