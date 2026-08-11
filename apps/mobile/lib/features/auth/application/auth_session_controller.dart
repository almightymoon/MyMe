import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment_config.dart';
import '../data/flutter_secure_session_store.dart';
import '../domain/secure_session_store.dart';

final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  if (kDebugMode && !EnvironmentConfig.isProduction) {
    return InMemorySecureSessionStore();
  }
  return FlutterSecureSessionStore();
});

final authSessionProvider =
    StateNotifierProvider<AuthSessionController, StoredAuthSession?>((ref) {
      return AuthSessionController(ref.watch(secureSessionStoreProvider));
    });

class AuthSessionController extends StateNotifier<StoredAuthSession?> {
  AuthSessionController(this._store, {StoredAuthSession? initial})
    : super(initial);

  final SecureSessionStore _store;

  Future<void> hydrate() async {
    state = await _store.read();
  }

  Future<void> signIn(StoredAuthSession session) async {
    await _store.write(session);
    state = session;
  }

  Future<void> signOut({required bool removeLocalCache}) async {
    await _store.clear();
    state = null;
    // Local cache removal is handled by AccountLocalStoreManager callers.
    // ignore: unused_local_variable
    final _ = removeLocalCache;
  }

  bool get isSignedIn => state != null;
}
