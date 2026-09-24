import 'package:crowdfans/components/profile/account_quick_setting_row.dart';
import 'package:crowdfans/components/profile/account_summary_row.dart';
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

void main() {
  testWidgets('CF-162: hub Seu Perfil com resumo e acessos rápidos', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/me/settings/account',
      routes: [
        GoRoute(
          path: '/me/settings/account',
          builder: (context, state) => const ProfileAccountScreen(),
        ),
        GoRoute(
          path: '/me/settings/account/bio',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/me/settings/account/photo',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_FakeAuthSessionNotifier.new),
        ],
        child: MaterialApp.router(
          theme: buildCrowdFansTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
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
    expect(find.text('URL pública da foto'), findsNothing);
    expect(find.byType(AccountSummaryRow), findsNWidgets(2));
    expect(find.byType(AccountQuickSettingRow), findsNWidgets(2));
  });
}
