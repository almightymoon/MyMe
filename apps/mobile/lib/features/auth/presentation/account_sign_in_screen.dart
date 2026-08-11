import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../application/auth_session_controller.dart';
import '../application/identity_auth_providers.dart';
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

  Future<void> _continue(Future<IdentityAuthResult> Function() signIn) async {
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
    await ref
        .read(authSessionProvider.notifier)
        .signIn(
          StoredAuthSession(
            userId: 'pending-exchange',
            deviceId: 'pending-device',
            clientGeneratedDeviceId: 'pending-client-device',
            provider: 'google',
            refreshToken: 'pending',
            authenticatedAt: DateTime.now().toUtc(),
          ),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    final onboardingComplete = ref.read(onboardingCompletionProvider);
    context.go(onboardingComplete ? RoutePaths.today : RoutePaths.onboarding);
  }

  String _messageFor(IdentityAuthStatus status) {
    switch (status) {
      case IdentityAuthStatus.network:
        return 'Internet is required for the first sign-in.';
      case IdentityAuthStatus.missingIdToken:
        return 'The provider did not return an identity token.';
      case IdentityAuthStatus.failed:
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
