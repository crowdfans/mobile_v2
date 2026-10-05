import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_change_email_screen.dart';
import 'package:crowdfans/screens/profile/profile_change_phone_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_credentials_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regressão: hub Segurança → Trocar telefone abre a página dedicada.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CF-217: hub Trocar telefone → ProfileChangePhoneScreen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Pages.profileSecurity,
      routes: [
        GoRoute(
          path: Pages.profileSecurity,
          builder: (context, state) => const ProfileSecurityScreen(),
        ),
        GoRoute(
          path: Pages.profileChangePassword,
          builder: (context, state) => const ProfileSecurityCredentialsScreen(),
        ),
        GoRoute(
          path: Pages.profileChangeEmail,
          builder: (context, state) => const ProfileChangeEmailScreen(),
        ),
        GoRoute(
          path: Pages.profileChangePhone,
          builder: (context, state) => const ProfileChangePhoneScreen(),
        ),
        GoRoute(
          path: Pages.profileConnectedDevices,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Segurança e Login'), findsOneWidget);

    await tester.tap(find.text('Trocar telefone'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(router.state.uri.path, Pages.profileChangePhone);
    expect(find.byType(ProfileChangePhoneScreen), findsOneWidget);
    expect(find.text('Atualize o telefone de recuperação'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Alterar senha'), findsNothing);
    expect(find.text('Trocar e-mail'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    expect(find.text('Segurança e login'), findsNothing);
  });
}
