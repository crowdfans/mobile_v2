import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_change_email_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_credentials_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regressão: hub Segurança → Trocar e-mail deve abrir a página dedicada
/// (não ProfileSecurityCredentialsScreen com abas / "Segurança e login").
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CF-165: hub Trocar e-mail → ProfileChangeEmailScreen', (
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
          path: Pages.profileSecurityCredentials,
          builder: (context, state) {
            if ((state.uri.queryParameters['mode'] ?? '').toLowerCase() ==
                'email') {
              return const ProfileChangeEmailScreen();
            }
            return ProfileSecurityCredentialsScreen(
              initialMode: state.uri.queryParameters['mode'],
            );
          },
        ),
        GoRoute(
          path: Pages.profileChangeEmail,
          builder: (context, state) => const ProfileChangeEmailScreen(),
        ),
        GoRoute(
          path: Pages.profileChangePhone,
          builder: (context, state) => const SizedBox.shrink(),
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

    await tester.tap(find.text('Trocar e-mail'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Pages.profileChangeEmail);
    expect(find.byType(ProfileChangeEmailScreen), findsOneWidget);
    expect(find.byType(ProfileSecurityCredentialsScreen), findsNothing);
    expect(find.text('Atualize o e-mail da sua conta'), findsOneWidget);
    expect(find.text('Alterar senha'), findsNothing);
    expect(find.textContaining('Firebase'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    // Header da página dedicada — não o título legado do hub com abas.
    expect(find.text('Trocar e-mail'), findsOneWidget);
    expect(find.text('Segurança e login'), findsNothing);
  });
}
