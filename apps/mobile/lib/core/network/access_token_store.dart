/// Memory-first access token. Never persisted to SharedPreferences.
class AccessTokenStore {
  String? _token;
  DateTime? _expiresAt;
  int _generation = 0;

  String? get token => _token;

  DateTime? get expiresAt => _expiresAt;

  int get generation => _generation;

  bool get isUsable {
    final token = _token;
    final expires = _expiresAt;
    if (token == null || token.isEmpty || expires == null) return false;
    return DateTime.now().toUtc().isBefore(
      expires.subtract(const Duration(seconds: 20)),
    );
  }

  void replace(String token, DateTime expiresAt) {
    _token = token;
    _expiresAt = expiresAt.toUtc();
    _generation += 1;
  }

  void clear() {
    _token = null;
    _expiresAt = null;
    _generation += 1;
  }
}
