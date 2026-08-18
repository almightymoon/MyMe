import 'auth_session_tokens.dart';

class AuthDeviceInfo {
  const AuthDeviceInfo({
    required this.clientGeneratedDeviceId,
    required this.platform,
    required this.appVersion,
    this.deviceLabel,
  });

  final String clientGeneratedDeviceId;
  final String platform;
  final String appVersion;
  final String? deviceLabel;

  Map<String, Object?> toJson() => {
    'clientGeneratedDeviceId': clientGeneratedDeviceId,
    'platform': platform,
    'appVersion': appVersion,
    if (deviceLabel != null) 'deviceLabel': deviceLabel,
  };
}

class AuthDeviceSession {
  const AuthDeviceSession({
    required this.id,
    required this.platform,
    required this.appVersion,
    required this.lastSeenAt,
    this.deviceLabel,
  });

  final String id;
  final String platform;
  final String appVersion;
  final DateTime lastSeenAt;
  final String? deviceLabel;
}

abstract interface class AuthApi {
  Future<AuthSessionTokens> signInWithGoogle({
    required String idToken,
    required AuthDeviceInfo device,
    String? nonce,
  });

  Future<AuthSessionTokens> signInWithApple({
    required String identityToken,
    required AuthDeviceInfo device,
    required String nonce,
    String? givenName,
    String? familyName,
  });

  Future<AuthSessionTokens> registerWithEmail({
    required String email,
    required String password,
    required AuthDeviceInfo device,
    String? displayName,
  });

  Future<AuthSessionTokens> signInWithEmail({
    required String email,
    required String password,
    required AuthDeviceInfo device,
  });

  Future<AuthSessionTokens> refreshSession({
    required String refreshToken,
    required AuthDeviceInfo device,
  });

  Future<void> logout(String refreshToken);

  Future<void> logoutAll();

  Future<Map<String, dynamic>> getCurrentUser();

  Future<List<AuthDeviceSession>> listDevices();

  Future<void> revokeDevice(String deviceId);

  Future<Map<String, dynamic>> exportAccount();

  Future<void> deleteAccount();
}
