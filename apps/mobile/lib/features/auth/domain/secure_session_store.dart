/// Platform-secure session. Never store access tokens or provider ID tokens.
abstract interface class SecureSessionStore {
  Future<StoredAuthSession?> read();

  Future<void> write(StoredAuthSession session);

  Future<void> clear();
}

class StoredAuthSession {
  StoredAuthSession({
    required this.userId,
    required this.deviceId,
    required this.clientGeneratedDeviceId,
    required this.provider,
    required this.refreshToken,
    required this.authenticatedAt,
    this.refreshTokenExpiresAt,
  }) {
    if (userId.isEmpty ||
        userId.startsWith('pending-') ||
        deviceId.startsWith('pending-') ||
        refreshToken == 'pending' ||
        refreshToken.isEmpty) {
      throw ArgumentError('Placeholder sessions are not allowed.');
    }
  }

  final String userId;
  final String deviceId;
  final String clientGeneratedDeviceId;
  final String provider;
  final String refreshToken;
  final DateTime authenticatedAt;
  final DateTime? refreshTokenExpiresAt;
}

class InMemorySecureSessionStore implements SecureSessionStore {
  StoredAuthSession? _session;

  @override
  Future<StoredAuthSession?> read() async => _session;

  @override
  Future<void> write(StoredAuthSession session) async {
    _session = session;
  }

  @override
  Future<void> clear() async {
    _session = null;
  }
}
