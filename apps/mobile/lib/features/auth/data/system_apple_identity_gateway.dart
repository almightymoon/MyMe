import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/identity_auth_gateway.dart';

/// Sign in with Apple. Returns the raw nonce for backend verification.
class SystemAppleIdentityGateway {
  Future<IdentityAuthResult> signIn() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerUnavailable,
        message: 'Sign in with Apple is available on iPhone and iPad.',
      );
    }
    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        return const IdentityAuthResult(
          status: IdentityAuthStatus.providerUnavailable,
        );
      }
      final rawNonce = _secureNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final token = credential.identityToken;
      if (token == null || token.isEmpty) {
        return const IdentityAuthResult(
          status: IdentityAuthStatus.missingIdToken,
        );
      }
      return IdentityAuthResult(
        status: IdentityAuthStatus.success,
        idToken: token,
        nonce: rawNonce,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return const IdentityAuthResult(status: IdentityAuthStatus.cancelled);
      }
      debugPrint('Apple Sign-In failed: ${error.code}');
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerFailure,
      );
    } on MissingPluginException {
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerUnavailable,
      );
    } on Object {
      return const IdentityAuthResult(
        status: IdentityAuthStatus.providerFailure,
      );
    }
  }

  static String _secureNonce([int length = 32]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
