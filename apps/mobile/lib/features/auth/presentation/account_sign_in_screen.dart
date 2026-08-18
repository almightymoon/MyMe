import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/application/providers/core_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
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
import 'widgets/auth_glass_field.dart';

class AccountSignInScreen extends ConsumerStatefulWidget {
  const AccountSignInScreen({super.key});

  @override
  ConsumerState<AccountSignInScreen> createState() =>
      _AccountSignInScreenState();
}

class _AccountSignInScreenState extends ConsumerState<AccountSignInScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _busy = false;
  bool _signUpMode = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter email and password to continue.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Use at least 8 characters for your password.');
      return;
    }
    if (_signUpMode && password != _confirmController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final device = await loadAuthDeviceInfo(
        ref.read(sharedPreferencesProvider),
      );
      final authApi = ref.read(authApiProvider);
      final tokens = _signUpMode
          ? await authApi.registerWithEmail(
              email: email,
              password: password,
              device: device,
              displayName: name.isEmpty ? null : name,
            )
          : await authApi.signInWithEmail(
              email: email,
              password: password,
              device: device,
            );
      await _storeSession(tokens, device.clientGeneratedDeviceId, 'email');
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = userFacingErrorMessage(error);
      });
    }
  }

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
      await _storeSession(tokens, device.clientGeneratedDeviceId, provider);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = userFacingErrorMessage(error);
      });
    }
  }

  Future<void> _storeSession(
    AuthSessionTokens tokens,
    String clientGeneratedDeviceId,
    String provider,
  ) async {
    ref
        .read(accessTokenStoreProvider)
        .replace(tokens.accessToken, tokens.accessTokenExpiresAt);
    await ref
        .read(authSessionProvider.notifier)
        .signIn(
          StoredAuthSession(
            userId: tokens.userId,
            deviceId: tokens.deviceId,
            clientGeneratedDeviceId: clientGeneratedDeviceId,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 52, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MeMy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge(color: AppColors.ember),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _signUpMode
                      ? 'Create an account with email and password. '
                            'Google and Apple are optional when they are configured.'
                      : 'Sign in with email and password. '
                            'Google and Apple are optional when they are configured.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.secondaryText,
                  ),
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
                if (_signUpMode)
                  AuthGlassField(
                    key: const Key('email_auth_name'),
                    controller: _nameController,
                    hint: AppStrings.fullNameHint,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                AuthGlassField(
                  key: const Key('email_auth_email'),
                  controller: _emailController,
                  hint: AppStrings.emailLabel,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                AuthGlassField(
                  key: const Key('email_auth_password'),
                  controller: _passwordController,
                  hint: AppStrings.passwordLabel,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  textInputAction: _signUpMode
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onSubmitted: _signUpMode || _busy
                      ? null
                      : (_) => _submitEmail(),
                  autofillHints: _signUpMode
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  suffix: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: _obscure ? AppColors.faintText : AppColors.ember,
                    ),
                  ),
                ),
                if (_signUpMode)
                  AuthGlassField(
                    key: const Key('email_auth_confirm'),
                    controller: _confirmController,
                    hint: AppStrings.confirmPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _busy ? null : (_) => _submitEmail(),
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                MemyPrimaryButton(
                  key: const Key('email_auth_submit'),
                  label: _busy
                      ? 'Signing in…'
                      : (_signUpMode ? AppStrings.signUp : AppStrings.signIn),
                  onPressed: _busy ? null : _submitEmail,
                ),
                TextButton(
                  key: const Key('email_auth_toggle'),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _signUpMode = !_signUpMode;
                          _error = null;
                        }),
                  child: Text(
                    _signUpMode
                        ? 'Already have an account? Sign in'
                        : 'Need an account? Sign up',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.ember,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'or',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MemyPrimaryButton(
                  key: const Key('continue_with_google'),
                  label: _busy ? 'Signing in…' : 'Continue with Google',
                  onPressed: _busy
                      ? null
                      : () => _continue(
                          ref
                              .read(identityAuthGatewayProvider)
                              .signInWithGoogle,
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
                            ref
                                .read(identityAuthGatewayProvider)
                                .signInWithApple,
                            provider: 'apple',
                          ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Internet is required the first time you sign in. '
                  'Privacy Policy and Terms are in Help.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
