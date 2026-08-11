class AuthSessionTokens {
  AuthSessionTokens({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.userId,
    required this.deviceId,
    required this.provider,
    required this.hasSynchronizedRecords,
    required this.bootstrapEmpty,
    required this.currentCursor,
    this.refreshTokenExpiresAt,
  }) {
    if (userId.startsWith('pending-') ||
        deviceId.startsWith('pending-') ||
        refreshToken == 'pending') {
      throw ArgumentError('Placeholder sessions are not allowed.');
    }
  }

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime? refreshTokenExpiresAt;
  final String userId;
  final String deviceId;
  final String provider;
  final bool hasSynchronizedRecords;
  final bool bootstrapEmpty;
  final String currentCursor;

  factory AuthSessionTokens.fromJson(
    Map<String, dynamic> json, {
    required String provider,
  }) {
    final user = json['user'];
    if (user is! Map) {
      throw const FormatException('Authenticated user missing.');
    }
    final userId = user['id']?.toString() ?? '';
    final deviceId = json['deviceId']?.toString() ?? '';
    final access = json['accessToken']?.toString() ?? '';
    final refresh = json['refreshToken']?.toString() ?? '';
    if (userId.isEmpty ||
        deviceId.isEmpty ||
        access.isEmpty ||
        refresh.isEmpty) {
      throw const FormatException('Incomplete authentication response.');
    }
    return AuthSessionTokens(
      accessToken: access,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt'] as String,
      ),
      refreshToken: refresh,
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] == null
          ? null
          : DateTime.parse(json['refreshTokenExpiresAt'] as String),
      userId: userId,
      deviceId: deviceId,
      provider: provider,
      hasSynchronizedRecords: json['hasSynchronizedRecords'] == true,
      bootstrapEmpty: json['bootstrapEmpty'] == true,
      currentCursor: '${json['currentCursor'] ?? '0'}',
    );
  }
}
