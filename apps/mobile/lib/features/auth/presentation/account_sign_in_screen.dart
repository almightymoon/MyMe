import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/application/providers/core_providers.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../application/auth_session_controller.dart';
import '../application/identity_auth_providers.dart';
import '../data/auth_device_info_factory.dart';
import '../domain/auth_session_tokens.dart';
import '../domain/identity_auth_gateway.dart';
import '../domain/secure_session_store.dart';
import 'widgets/auth_atmosphere.dart';

class AccountSignInScreen extends ConsumerStatefulWidget {
  const AccountSignInScreen({super.key});

  @override
  ConsumerState<AccountSignInScreen> createState() =>
      _AccountSignInScreenState();
}

class _AccountSignInScreenState extends ConsumerState<AccountSignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _continue(
    Future<IdentityAuthResult> Function() signIn, {
    required String provider,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await signIn();
    if (!mounted) return;
    if (result.status == IdentityAuthStatus.cancelled) {
      setState(() => _busy = false);
      return;
    }
    if (!result.isSuccess) {
      setState(() {
        _busy = false;
        _error = result.message ?? _messageFor(result.status);
      });
      return;
    }
    try {
      final device = await loadAuthDeviceInfo(
        ref.read(sharedPreferencesProvider),
      );
      final authApi = ref.read(authApiProvider);
      late final AuthSessionTokens tokens;
      if (provider == 'apple') {
        tokens = await authApi.signInWithApple(
          identityToken: result.idToken!,
          device: device,
          nonce: result.nonce ?? '',
          givenName: result.givenName,
          familyName: result.familyName,
        );
      } else {
        tokens = await authApi.signInWithGoogle(
          idToken: result.idToken!,
          device: device,
          nonce: result.nonce,
        );
      }
      ref
          .read(accessTokenStoreProvider)
          .replace(tokens.accessToken, tokens.accessTokenExpiresAt);
      await ref
          .read(authSessionProvider.notifier)
          .signIn(
            StoredAuthSession(
              userId: tokens.userId,
              deviceId: tokens.deviceId,
              clientGeneratedDeviceId: device.clientGeneratedDeviceId,
              provider: provider,
              refreshToken: tokens.refreshToken,
              authenticatedAt: DateTime.now().toUtc(),
              refreshTokenExpiresAt: tokens.refreshTokenExpiresAt,
            ),
          );
      if (!mounted) return;
      setState(() => _busy = false);
      final onboardingComplete = ref.read(onboardingCompletionProvider);
      context.go(onboardingComplete ? RoutePaths.today : RoutePaths.onboarding);
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not finish sign-in. Try again.';
      });
    }
  }

  String _messageFor(IdentityAuthStatus status) {
    switch (status) {
      case IdentityAuthStatus.network:
        return 'Internet is required for the first sign-in.';
      case IdentityAuthStatus.missingIdToken:
        return 'The provider did not return an identity token.';
      case IdentityAuthStatus.configurationError:
        return 'Sign-in is not configured on this build.';
      case IdentityAuthStatus.providerUnavailable:
        return 'This sign-in option is not available on this device.';
      case IdentityAuthStatus.failed:
      case IdentityAuthStatus.providerFailure:
        return 'Could not sign in. Try again.';
      case IdentityAuthStatus.cancelled:
      case IdentityAuthStatus.success:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    return Scaffold(
      body: AuthAtmosphere(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 52, 28, 24),
            children: [
              Text(
                'MeMy',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge(color: AppColors.ember),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Continue with Google or Sign in with Apple. '
                'Your data remains available offline after sign-in.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(color: AppColors.health),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              MemyPrimaryButton(
                key: const Key('continue_with_google'),
                label: _busy ? 'Signing in…' : 'Continue with Google',
                onPressed: _busy
                    ? null
                    : () => _continue(
                        ref.read(identityAuthGatewayProvider).signInWithGoogle,
                        provider: 'google',
                      ),
              ),
              if (showApple) ...[
                const SizedBox(height: AppSpacing.sm),
                MemyPrimaryButton(
                  key: const Key('continue_with_apple'),
                  label: 'Continue with Apple',
                  onPressed: _busy
                      ? null
                      : () => _continue(
                          ref.read(identityAuthGatewayProvider).signInWithApple,
                          provider: 'apple',
                        ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Internet is required the first time you sign in. '
                'Privacy Policy and Terms are in Help.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
