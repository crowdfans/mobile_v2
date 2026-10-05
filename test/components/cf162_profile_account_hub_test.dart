import 'package:crowdfans/components/profile/account_quick_setting_row.dart';
import 'package:crowdfans/components/profile/account_summary_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/profile/profile_account_screen.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'fan-1',
        displayName: 'fan/alineduarte',
        name: 'Aline Duarte',
        description: 'Bio de teste',
        photoUrl: 'https://example.com/a.png',
        isArtist: false,
      ),
    );
  }
}

/// CF-162 — hub Seu Perfil vs print (image.png LEFT).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(GoRouter router) {
    return ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(_FakeAuthSessionNotifier.new),
      ],
      child: MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
  }

  testWidgets('CF-162: hub Seu Perfil com resumo e acessos rápidos', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Pages.profileAccount,
      routes: [
        GoRoute(
          path: Pages.profileAccount,
          builder: (context, state) => const ProfileAccountScreen(),
        ),
        GoRoute(
          path: Pages.profileEditBio,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: Pages.profilePhoto,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Seu Perfil'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('Nome de usuário'), findsOneWidget);
    expect(find.text('alineduarte'), findsOneWidget);
    expect(find.text('Configurações rápidas'), findsOneWidget);
    expect(find.text('Editar bio'), findsOneWidget);
    expect(find.text('Atualize sua descrição de perfil.'), findsOneWidget);
    expect(find.text('Foto de perfil'), findsOneWidget);
    expect(find.text('Trocar imagem da conta.'), findsOneWidget);
    expect(
      find.text('Seu perfil será exibido como fan/alineduarte'),
      findsOneWidget,
    );

    // Formulário antigo (print RIGHT) não deve aparecer no hub.
    expect(find.text('Editar perfil'), findsNothing);
    expect(find.text('URL pública da foto'), findsNothing);
    expect(find.text('Galeria'), findsNothing);
    expect(find.text('Câmera'), findsNothing);
    expect(find.text('Bio'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(AccountSummaryRow), findsNWidgets(2));
    expect(find.byType(AccountQuickSettingRow), findsNWidgets(2));

    // Ordem visual vs print LEFT.
    final titles = [
      'Seu Perfil',
      'Nome',
      'Nome de usuário',
      'Configurações rápidas',
      'Editar bio',
      'Foto de perfil',
      'Seu perfil será exibido como fan/alineduarte',
    ];
    double? lastY;
    for (final title in titles) {
      final y = tester.getTopLeft(find.text(title)).dy;
      if (lastY != null) {
        expect(y, greaterThan(lastY), reason: '$title deve vir depois');
      }
      lastY = y;
    }
  });

  testWidgets('CF-162: Editar bio e Foto de perfil abrem rotas dedicadas', (
    tester,
  ) async {
    String? lastLocation;
    final router = GoRouter(
      initialLocation: Pages.profileAccount,
      routes: [
        GoRoute(
          path: Pages.profileAccount,
          builder: (context, state) => const ProfileAccountScreen(),
        ),
        GoRoute(
          path: Pages.profileEditBio,
          builder: (context, state) {
            lastLocation = state.uri.path;
            return const Scaffold(
              body: Center(child: Text('dest-bio')),
            );
          },
        ),
        GoRoute(
          path: Pages.profilePhoto,
          builder: (context, state) {
            lastLocation = state.uri.path;
            return const Scaffold(
              body: Center(child: Text('dest-photo')),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const Key('account-quick-bio')));
    await tester.pumpAndSettle();
    expect(lastLocation, Pages.profileEditBio);
    expect(find.text('dest-bio'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('account-quick-photo')));
    await tester.pumpAndSettle();
    expect(lastLocation, Pages.profilePhoto);
    expect(find.text('dest-photo'), findsOneWidget);
  });
}
