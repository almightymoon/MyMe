import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/environment_config.dart';
import '../domain/identity_auth_gateway.dart';

/// Native Google Sign-In. Never constructs a MeMy session.
class SystemGoogleIdentityGateway {
  SystemGoogleIdentityGateway({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const ['email', 'openid', 'profile'],
            serverClientId: EnvironmentConfig.googleServerClientId.isEmpty
                ? null
                : EnvironmentConfig.googleServerClientId,
            clientId: EnvironmentConfig.googleIosClientId.isEmpty
                ? null
                : EnvironmentConfig.googleIosClientId,
          );

  final GoogleSignIn _googleSignIn;

  Future<IdentityAuthResult> signIn() async {
    if (EnvironmentConfig.usesAccountAuth &&
        EnvironmentConfig.googleServerClientId.isEmpty) {
      return const IdentityAuthResult(
        status: IdentityAuthStatus.configurationError,
        message: 'Google Sign-In is not configured on this build.',
      );
    }
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return const IdentityAuthResult(status: IdentityAuthStatus.cancelled);
      }
      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const IdentityAuthResult(
          status: IdentityAuthStatus.missingIdToken,
        );
      }
      return IdentityAuthResult(
        status: IdentityAuthStatus.success,
        idToken: idToken,
        givenName: account.displayName,
      );
    } on MissingPluginException {
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerUnavailable,
        message: 'Google Sign-In is not available on this device.',
      );
    } on PlatformException catch (error) {
      if (error.code == 'sign_in_canceled' || error.code == '12501') {
        return const IdentityAuthResult(status: IdentityAuthStatus.cancelled);
      }
      if (error.code == 'network_error') {
        return const IdentityAuthResult(status: IdentityAuthStatus.network);
      }
      debugPrint('Google Sign-In failed: ${error.code}');
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerFailure,
      );
    } on Object {
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerFailure,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } on Object {
      // Best-effort provider cleanup.
    }
  }
}
