import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/auth/data/auth_device_info_factory.dart';
import '../../features/auth/data/dio_auth_api.dart';
import '../../features/auth/domain/auth_api.dart';
import '../../features/auth/domain/secure_session_store.dart';
import '../application/providers/core_providers.dart';
import '../config/environment_config.dart';
import 'access_token_store.dart';
import 'api_client.dart';

final accessTokenStoreProvider = Provider<AccessTokenStore>((ref) {
  return AccessTokenStore();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokens = ref.watch(accessTokenStoreProvider);
  return ApiClient(
    accessTokenStore: tokens,
    attachDevUserHeader:
        kDebugMode &&
        !EnvironmentConfig.isProduction &&
        !EnvironmentConfig.usesAccountAuth,
    refresher: () => _refreshSession(ref),
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  return DioAuthApi(ref.watch(apiClientProvider));
});

Future<bool> _refreshSession(Ref ref) async {
  final session = ref.read(authSessionProvider);
  if (session == null) return false;
  try {
    final refreshClient = ApiClient(
      accessTokenStore: AccessTokenStore(),
      attachDevUserHeader: false,
      enableLogging: false,
    );
    final api = DioAuthApi(refreshClient);
    final device = await loadAuthDeviceInfo(
      ref.read(sharedPreferencesProvider),
    );
    final refreshed = await api.refreshSession(
      refreshToken: session.refreshToken,
      device: device,
    );
    ref
        .read(accessTokenStoreProvider)
        .replace(refreshed.accessToken, refreshed.accessTokenExpiresAt);
    await ref
        .read(authSessionProvider.notifier)
        .signIn(
          StoredAuthSession(
            userId: refreshed.userId,
            deviceId: refreshed.deviceId,
            clientGeneratedDeviceId: session.clientGeneratedDeviceId,
            provider: session.provider,
            refreshToken: refreshed.refreshToken,
            authenticatedAt: DateTime.now().toUtc(),
            refreshTokenExpiresAt: refreshed.refreshTokenExpiresAt,
          ),
        );
    return true;
  } on Object {
    return false;
  }
}
