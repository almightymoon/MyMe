class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.fullName,
    required this.initials,
    this.tagline,
    this.email,
  });

  final String id;
  final String displayName;
  final String fullName;
  final String initials;
  final String? tagline;
  final String? email;

  static const empty = UserProfile(
    id: 'anonymous',
    displayName: 'Friend',
    fullName: 'Guest',
    initials: '?',
    tagline: null,
    email: null,
  );
}
