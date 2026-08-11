import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/features/auth/application/identity_auth_providers.dart';
import 'package:memy/features/auth/domain/identity_auth_gateway.dart';
import 'package:memy/features/auth/presentation/account_sign_in_screen.dart';

void main() {
  testWidgets('production welcome has Google and no demo credentials', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          identityAuthGatewayProvider.overrideWithValue(
            FakeIdentityAuthGateway(),
          ),
        ],
        child: const MaterialApp(home: AccountSignInScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('continue_with_google')), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.text('Sign In'), findsNothing);
    expect(find.text('Sign Up'), findsNothing);
    expect(find.text('Forgot Password'), findsNothing);
  });
}
