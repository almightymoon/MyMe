enum IdentityAuthStatus {
  success,
  cancelled,
  failed,
  missingIdToken,
  network,
  providerUnavailable,
  configurationError,
  providerFailure,
}

class IdentityAuthResult {
  const IdentityAuthResult({
    required this.status,
    this.idToken,
    this.nonce,
    this.givenName,
    this.familyName,
    this.message,
  });

  final IdentityAuthStatus status;
  final String? idToken;
  final String? nonce;
  final String? givenName;
  final String? familyName;
  final String? message;

  bool get isSuccess =>
      status == IdentityAuthStatus.success &&
      idToken != null &&
      idToken!.isNotEmpty;
}

abstract interface class IdentityAuthGateway {
  Future<IdentityAuthResult> signInWithGoogle();

  Future<IdentityAuthResult> signInWithApple();
}

class FakeIdentityAuthGateway implements IdentityAuthGateway {
  FakeIdentityAuthGateway({
    this.google = const IdentityAuthResult(
      status: IdentityAuthStatus.cancelled,
    ),
    this.apple = const IdentityAuthResult(status: IdentityAuthStatus.cancelled),
  });

  IdentityAuthResult google;
  IdentityAuthResult apple;

  @override
  Future<IdentityAuthResult> signInWithGoogle() async => google;

  @override
  Future<IdentityAuthResult> signInWithApple() async => apple;
}
