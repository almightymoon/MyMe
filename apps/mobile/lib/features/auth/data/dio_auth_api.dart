import '../../../core/network/api_client.dart';
import '../domain/auth_api.dart';
import '../domain/auth_session_tokens.dart';

class DioAuthApi implements AuthApi {
  DioAuthApi(this._client);

  final ApiClient _client;

  @override
  Future<AuthSessionTokens> signInWithGoogle({
    required String idToken,
    required AuthDeviceInfo device,
    String? nonce,
  }) {
    return _exchange('/auth/google', {
      'idToken': idToken,
      'device': device.toJson(),
      'nonce': ?nonce,
    }, provider: 'google');
  }

  @override
  Future<AuthSessionTokens> signInWithApple({
    required String identityToken,
    required AuthDeviceInfo device,
    required String nonce,
    String? givenName,
    String? familyName,
  }) {
    return _exchange('/auth/apple', {
      'identityToken': identityToken,
      'nonce': nonce,
      'device': device.toJson(),
      'givenName': ?givenName,
      'familyName': ?familyName,
    }, provider: 'apple');
  }

  @override
  Future<AuthSessionTokens> refreshSession({
    required String refreshToken,
    required AuthDeviceInfo device,
  }) {
    return _exchange('/auth/refresh', {
      'refreshToken': refreshToken,
      'device': device.toJson(),
    }, provider: 'refresh');
  }

  Future<AuthSessionTokens> _exchange(
    String path,
    Map<String, Object?> body, {
    required String provider,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(path, data: body);
    final data = Map<String, dynamic>.from(response.data ?? const {});
    return AuthSessionTokens.fromJson(data, provider: provider);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _client.post<void>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }

  @override
  Future<void> logoutAll() async {
    await _client.post<void>('/auth/logout-all');
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _client.get<Map<String, dynamic>>('/me');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  @override
  Future<List<AuthDeviceSession>> listDevices() async {
    final response = await _client.get<List<dynamic>>('/me/devices');
    return (response.data ?? const [])
        .whereType<Map>()
        .map(
          (row) => AuthDeviceSession(
            id: row['id'].toString(),
            platform: row['platform']?.toString() ?? '',
            appVersion: row['appVersion']?.toString() ?? '',
            lastSeenAt: DateTime.parse(row['lastSeenAt'] as String),
            deviceLabel: row['deviceLabel']?.toString(),
          ),
        )
        .toList();
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    await _client.delete<void>('/me/devices/$deviceId');
  }

  @override
  Future<Map<String, dynamic>> exportAccount() async {
    final response = await _client.get<Map<String, dynamic>>('/me/export');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  @override
  Future<void> deleteAccount() async {
    await _client.delete<void>(
      '/me',
      data: const {'confirmation': 'DELETE MY ACCOUNT'},
    );
  }
}
