import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/auth/application/identity_auth_providers.dart';
import 'package:memy/features/auth/domain/identity_auth_gateway.dart';
import 'package:memy/features/auth/domain/secure_session_store.dart';

void main() {
  test(
    'account auth uses the system gateway, never FakeIdentityAuthGateway',
    () {
      final gateway = createIdentityAuthGateway(usesAccountAuth: true);
      expect(gateway, isA<SystemIdentityAuthGateway>());
      expect(gateway, isNot(isA<FakeIdentityAuthGateway>()));
    },
  );

  test('demo/internal builds may use the fake gateway', () {
    final gateway = createIdentityAuthGateway(usesAccountAuth: false);
    expect(gateway, isA<FakeIdentityAuthGateway>());
  });

  test('placeholder sessions are rejected', () {
    expect(
      () => StoredAuthSession(
        userId: 'pending-exchange',
        deviceId: 'pending-device',
        clientGeneratedDeviceId: 'pending-client-device',
        provider: 'google',
        refreshToken: 'pending',
        authenticatedAt: DateTime.utc(2026, 8, 11),
      ),
      throwsArgumentError,
    );
  });
}
