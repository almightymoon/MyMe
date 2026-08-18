import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
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
import 'widgets/auth_wave_button.dart';

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
  bool _acceptedTerms = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    if (_busy) return;
    setState(() {
      _signUpMode = !_signUpMode;
      _error = null;
    });
  }

  Future<void> _submitEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_signUpMode) {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Fill in all fields to create your account.');
        return;
      }
      if (password != _confirmController.text) {
        setState(() => _error = 'Passwords do not match.');
        return;
      }
      if (!_acceptedTerms) {
        setState(() => _error = 'Accept the terms to continue.');
        return;
      }
    } else if (email.isEmpty || password.isEmpty) {
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
              displayName: name,
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

  Widget _providerLinks() {
    final showApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      children: [
        TextButton(
          key: const Key('continue_with_google'),
          onPressed: _busy
              ? null
              : () => _continue(
                  ref.read(identityAuthGatewayProvider).signInWithGoogle,
                  provider: 'google',
                ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.ember,
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
          child: Text(
            'Continue with Google',
            style: AppTextStyles.bodySmall(
              color: AppColors.ember,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (showApple)
          TextButton(
            key: const Key('continue_with_apple'),
            onPressed: _busy
                ? null
                : () => _continue(
                    ref.read(identityAuthGatewayProvider).signInWithApple,
                    provider: 'apple',
                  ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ember,
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
            child: Text(
              'Continue with Apple',
              style: AppTextStyles.bodySmall(
                color: AppColors.ember,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  List<Widget> _signInFields() {
    return [
      Text(
        AppStrings.appName,
        textAlign: TextAlign.center,
        style: AppTextStyles.displayLarge(color: AppColors.ember),
      ),
      const SizedBox(height: 8),
      Text(
        AppStrings.tagline,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium(
          color: AppColors.primaryText,
        ).copyWith(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 18),
      Center(
        child: SvgPicture.asset(
          'assets/images/branding/logo.svg',
          width: 148,
          height: 123,
          placeholderBuilder: (_) => const SizedBox(width: 148, height: 123),
        ),
      ),
      const SizedBox(height: 22),
      AuthGlassField(
        key: const Key('email_auth_email'),
        controller: _emailController,
        hint: AppStrings.emailOrPhoneHint,
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
      ),
      AuthGlassField(
        key: const Key('email_auth_password'),
        controller: _passwordController,
        hint: AppStrings.passwordLabel,
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _obscure,
        textInputAction: TextInputAction.done,
        onSubmitted: _busy ? null : (_) => _submitEmail(),
        autofillHints: const [AutofillHints.password],
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
      const SizedBox(height: 16),
      if (_error != null) ...[
        Text(
          _error!,
          style: AppTextStyles.bodySmall(color: AppColors.health),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
      MemyPrimaryButton(
        key: const Key('email_auth_submit'),
        label: _busy ? 'Signing in…' : AppStrings.signIn,
        onPressed: _busy ? null : _submitEmail,
      ),
      const SizedBox(height: 8),
      _providerLinks(),
    ];
  }

  List<Widget> _signUpFields() {
    return [
      Row(
        children: [
          _AuthBackButton(onPressed: _toggleMode),
          Expanded(
            child: Text(
              AppStrings.appName,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium(
                color: AppColors.ember,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
      const SizedBox(height: 20),
      Text(AppStrings.createAccountTitle, style: AppTextStyles.displayMedium()),
      const SizedBox(height: 8),
      Text(AppStrings.createAccountSubtitle, style: AppTextStyles.bodyMedium()),
      const SizedBox(height: 22),
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
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
        suffix: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
            color: AppColors.faintText,
          ),
        ),
      ),
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
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _acceptedTerms,
              activeColor: AppColors.ember,
              onChanged: (value) =>
                  setState(() => _acceptedTerms = value ?? false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.acceptTerms,
              style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: AppTextStyles.bodySmall(color: AppColors.health)),
      ],
      const SizedBox(height: 14),
      MemyPrimaryButton(
        key: const Key('email_auth_submit'),
        label: _busy ? 'Signing in…' : AppStrings.signUp,
        onPressed: _busy ? null : _submitEmail,
      ),
      const SizedBox(height: 8),
      _providerLinks(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthAtmosphere(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: _signUpMode
                      ? const EdgeInsets.fromLTRB(28, 44, 28, 8)
                      : const EdgeInsets.fromLTRB(28, 52, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _signUpMode ? _signUpFields() : _signInFields(),
                  ),
                ),
              ),
              AuthWaveButton(
                key: const Key('email_auth_toggle'),
                label: _signUpMode ? AppStrings.signIn : AppStrings.signUp,
                onPressed: _toggleMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.hairline,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.chevron_left_rounded, size: 22),
        ),
      ),
    );
  }
}
