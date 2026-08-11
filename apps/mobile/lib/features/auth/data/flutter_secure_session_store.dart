import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/secure_session_store.dart';

/// Platform keychain / Keystore session. Never write these keys to
/// SharedPreferences.
class FlutterSecureSessionStore implements SecureSessionStore {
  FlutterSecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _userId = 'memy.session.userId';
  static const _deviceId = 'memy.session.deviceId';
  static const _clientDeviceId = 'memy.session.clientDeviceId';
  static const _provider = 'memy.session.provider';
  static const _refresh = 'memy.session.refresh';
  static const _authenticatedAt = 'memy.session.authenticatedAt';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredAuthSession?> read() async {
    final userId = await _storage.read(key: _userId);
    final refresh = await _storage.read(key: _refresh);
    final deviceId = await _storage.read(key: _deviceId);
    final clientDeviceId = await _storage.read(key: _clientDeviceId);
    final provider = await _storage.read(key: _provider);
    final authenticatedAt = await _storage.read(key: _authenticatedAt);
    if (userId == null ||
        refresh == null ||
        deviceId == null ||
        clientDeviceId == null ||
        provider == null ||
        authenticatedAt == null) {
      return null;
    }
    return StoredAuthSession(
      userId: userId,
      deviceId: deviceId,
      clientGeneratedDeviceId: clientDeviceId,
      provider: provider,
      refreshToken: refresh,
      authenticatedAt: DateTime.parse(authenticatedAt),
    );
  }

  @override
  Future<void> write(StoredAuthSession session) async {
    await _storage.write(key: _userId, value: session.userId);
    await _storage.write(key: _deviceId, value: session.deviceId);
    await _storage.write(
      key: _clientDeviceId,
      value: session.clientGeneratedDeviceId,
    );
    await _storage.write(key: _provider, value: session.provider);
    await _storage.write(key: _refresh, value: session.refreshToken);
    await _storage.write(
      key: _authenticatedAt,
      value: session.authenticatedAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _userId);
    await _storage.delete(key: _deviceId);
    await _storage.delete(key: _clientDeviceId);
    await _storage.delete(key: _provider);
    await _storage.delete(key: _refresh);
    await _storage.delete(key: _authenticatedAt);
  }
}
