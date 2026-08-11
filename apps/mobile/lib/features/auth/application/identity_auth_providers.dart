import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment_config.dart';
import '../data/system_apple_identity_gateway.dart';
import '../data/system_google_identity_gateway.dart';
import '../domain/identity_auth_gateway.dart';

IdentityAuthGateway createIdentityAuthGateway({
  required bool usesAccountAuth,
  SystemGoogleIdentityGateway? google,
  SystemAppleIdentityGateway? apple,
}) {
  if (usesAccountAuth) {
    return SystemIdentityAuthGateway(
      google: google ?? SystemGoogleIdentityGateway(),
      apple: apple ?? SystemAppleIdentityGateway(),
    );
  }
  return FakeIdentityAuthGateway();
}

class SystemIdentityAuthGateway implements IdentityAuthGateway {
  SystemIdentityAuthGateway({required this.google, required this.apple});

  final SystemGoogleIdentityGateway google;
  final SystemAppleIdentityGateway apple;

  @override
  Future<IdentityAuthResult> signInWithGoogle() => google.signIn();

  @override
  Future<IdentityAuthResult> signInWithApple() => apple.signIn();
}

final identityAuthGatewayProvider = Provider<IdentityAuthGateway>((ref) {
  return createIdentityAuthGateway(
    usesAccountAuth: EnvironmentConfig.usesAccountAuth,
  );
});
