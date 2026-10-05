import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/profile/profile_settings_screen.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Auth fake — conta logouts para asserts red/edge (CF-259).
class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  var logoutCalls = 0;

  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'fan-1',
        displayName: 'fan/teste',
        name: 'Fan Teste',
        description: '',
        photoUrl: '',
        isArtist: false,
      ),
    );
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    state = const AuthSession(isLoading: false);
  }
}

/// CF-259 — Configurações: scroll, push único e Sair com confirmação.
/// Obrigatório Gustavo: green / red / edge.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthSessionNotifier auth;

  Widget wrap(GoRouter router) {
    auth = _FakeAuthSessionNotifier();
    return ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => auth),
      ],
      child: MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
  }

  GoRouter buildRouter({List<RouteBase>? extraRoutes}) {
    return GoRouter(
      initialLocation: Pages.profileSettings,
      routes: [
        GoRoute(
          path: Pages.profileSettings,
          builder: (context, state) => const ProfileSettingsScreen(),
        ),
        GoRoute(
          path: Pages.profileSecurity,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('security-child')),
          ),
        ),
        GoRoute(
          path: Pages.profileHelp,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('help-child')),
          ),
        ),
        ...?extraRoutes,
      ],
    );
  }

  ScrollController settingsController(WidgetTester tester) {
    final list = tester.widget<ListView>(
      find.byKey(ProfileSettingsScreen.scrollStorageKey),
    );
    return list.controller!;
  }

  group('CF-259 green', () {
    test('ListView do hub usa PageStorageKey profile-settings', () {
      expect(
        ProfileSettingsScreen.scrollStorageKey.value,
        'profile-settings',
      );
    });

    testWidgets('rolar → abrir opção → voltar restaura offset', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(wrap(router));
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Sair da conta'), findsOneWidget);

      final controller = settingsController(tester);
      expect(controller.hasClients, isTrue);
      final target = controller.position.maxScrollExtent.clamp(120.0, 400.0);
      controller.jumpTo(target);
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(target, 0.5));

      await tester.tap(find.byKey(const Key('settings-item-security')));
      await tester.pumpAndSettle();
      expect(find.text('security-child'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
      final restored = settingsController(tester);
      expect(restored.offset, closeTo(target, 0.5));
    });

    testWidgets('Sair confirma e chama logout', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(wrap(router));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('settings-item-logout')));
      await tester.tap(find.byKey(const Key('settings-item-logout')));
      await tester.pumpAndSettle();

      expect(find.text('Deseja encerrar a sessão?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Sair'));
      await tester.pumpAndSettle();
      expect(auth.logoutCalls, 1);
    });
  });

  group('CF-259 red', () {
    testWidgets('Cancelar Sair não encerra sessão', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(wrap(router));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('settings-item-logout')));
      await tester.tap(find.byKey(const Key('settings-item-logout')));
      await tester.pumpAndSettle();
      expect(find.text('Deseja encerrar a sessão?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(auth.logoutCalls, 0);
      expect(find.text('Configurações'), findsOneWidget);
    });

    testWidgets('toque rápido não empilha rota duplicada', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(wrap(router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings-item-security')));
      // Segundo toque enquanto `_openingRoute` ainda bloqueia.
      await tester.tap(find.byKey(const Key('settings-item-security')));
      await tester.pumpAndSettle();

      expect(find.text('security-child'), findsOneWidget);
      // Um único pop volta ao hub — não há segunda rota security empilhada.
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('security-child'), findsNothing);
      expect(router.canPop(), isFalse);
    });
  });

  group('CF-259 edge', () {
    testWidgets('offset zero permanece zero após navegar e voltar', (
      tester,
    ) async {
      final router = buildRouter();
      await tester.pumpWidget(wrap(router));
      await tester.pumpAndSettle();

      final controller = settingsController(tester);
      expect(controller.offset, 0);

      await tester.tap(find.byKey(const Key('settings-item-help')));
      await tester.pumpAndSettle();
      expect(find.text('help-child'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(settingsController(tester).offset, 0);
    });

    testWidgets('lista longa: Sair permanece alcançável após scroll', (
      tester,
    ) async {
      final router = buildRouter();
      await tester.pumpWidget(wrap(router));
      await tester.pumpAndSettle();

      final controller = settingsController(tester);
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings-item-logout')), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings-item-logout')));
      await tester.pumpAndSettle();
      expect(find.text('Deseja encerrar a sessão?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(auth.logoutCalls, 0);
    });
  });
}
