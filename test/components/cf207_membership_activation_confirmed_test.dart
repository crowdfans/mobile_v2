import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_badge.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_card.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_info_note.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_membership_activation_confirmed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('CF-207 green — sucesso / print', () {
    testWidgets(
      'confirmação vincula artista e preço reais; preço com espaço /mês',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const ProfileMembershipActivationConfirmedScreen(
              artistName: 'Banda Uelo',
              artistHandle: 'bandauelo',
              pricePerMonth: 100,
              artistId: 'artist-1',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Membership ativo'), findsOneWidget);
        expect(find.text('Oficialmente do bando!'), findsOneWidget);
        expect(
          find.text(
            'Agora você apoia Banda Uelo todo mês e entra no círculo mais próximo da fanbase.',
          ),
          findsOneWidget,
        );
        expect(find.text('Banda Uelo'), findsWidgets);
        expect(find.text('@bandauelo'), findsOneWidget);
        expect(find.text('100 /mês'), findsOneWidget);
        expect(find.text('100/mês'), findsNothing);
        expect(find.text('240 /mês'), findsNothing);
        expect(find.text('1 mês'), findsOneWidget);
        expect(find.byType(MembershipActivationConfirmedBadge), findsOneWidget);
        expect(find.byType(MembershipActivationConfirmedCard), findsOneWidget);
        expect(
          find.byType(MembershipActivationConfirmedInfoNote),
          findsOneWidget,
        );
        expect(
          find.text(
            'Fica de olho nas notificações, porque sempre que rolar algo novo, você vai receber primeiro.',
          ),
          findsOneWidget,
        );
        expect(find.text('Fechar'), findsOneWidget);
        expect(Pages.profileMemberships, '/me/settings/memberships');
        expect(
          Pages.profileMembershipActivationConfirmedOf(
            artistName: 'Banda Uelo',
            pricePerMonth: 100,
          ),
          contains('pricePerMonth=100'),
        );
        expect(find.byType(AppButton), findsOneWidget);
      },
    );

    testWidgets(
      'deep-link seeded (print helper) Banda Uelo 240 /mês e Fechar → memberships',
      (tester) async {
        expect(CfTempMocks.useMembershipActivationConfirmedFixtures, isFalse);
        expect(cfTempMockMembershipSummary.pricePerMonth, 240);
        expect(cfTempMockMembershipSummary.artistName, 'Banda Uelo');

        final router = GoRouter(
          initialLocation: Pages.profileMembershipActivationConfirmedOf(
            artistName: cfTempMockMembershipSummary.artistName,
            artistHandle: cfTempMockMembershipSummary.artistHandle,
            artistId: cfTempMockMembershipSummary.artistId,
            pricePerMonth: cfTempMockMembershipSummary.pricePerMonth,
            periodLabel: cfTempMockMembershipSummary.periodLabel,
          ),
          routes: [
            GoRoute(
              path: Pages.profileMembershipActivationConfirmed,
              builder: (context, state) =>
                  ProfileMembershipActivationConfirmedScreen(
                artistName: state.uri.queryParameters['artistName'] ?? '',
                pricePerMonth:
                    int.tryParse(
                      state.uri.queryParameters['pricePerMonth'] ?? '',
                    ) ??
                    0,
                artistId: state.uri.queryParameters['artistId'],
                artistHandle: state.uri.queryParameters['artistHandle'],
                periodLabel:
                    state.uri.queryParameters['periodLabel'] ?? '1 mês',
              ),
            ),
            GoRoute(
              path: Pages.profileMemberships,
              builder: (context, state) =>
                  const Scaffold(body: Text('meus-memberships')),
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

        expect(find.text('Membership ativo'), findsOneWidget);
        expect(find.text('Oficialmente do bando!'), findsOneWidget);
        expect(find.textContaining('Banda Uelo'), findsWidgets);
        expect(find.text('@bandauelo'), findsOneWidget);
        expect(find.text('240 /mês'), findsOneWidget);
        expect(find.text('1 mês'), findsOneWidget);

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();
        expect(find.text('meus-memberships'), findsOneWidget);
      },
    );

    testWidgets('Confetti excluída da semântica (A11Y-01)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileMembershipActivationConfirmedScreen(
            artistName: 'Banda Uelo',
            pricePerMonth: 240,
          ),
        ),
      );
      await tester.pump();

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(
        images.any(
          (image) =>
              image.image is AssetImage &&
              (image.image as AssetImage).assetName ==
                  'assets/images/Confetti.png' &&
              image.excludeFromSemantics,
        ),
        isTrue,
      );
    });
  });

  group('CF-207 red — inválido / bloqueado / não-membership', () {
    testWidgets('não usa copy de recarga (CF-204) na confirmação de membership', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileMembershipActivationConfirmedScreen(
            artistName: 'Banda Uelo',
            pricePerMonth: 240,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pagamento confirmado'), findsNothing);
      expect(find.text('Carteira cheia!'), findsNothing);
      expect(find.text('Recarga concluída'), findsNothing);
      expect(find.textContaining('Jam Coins chegaram'), findsNothing);
    });

    testWidgets('preço real 100 não inventa 240 do print', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileMembershipActivationConfirmedScreen(
            artistName: 'Marinhos',
            artistHandle: '@marinhos',
            pricePerMonth: 100,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Marinhos'), findsOneWidget);
      expect(find.text('100 /mês'), findsOneWidget);
      expect(find.text('240 /mês'), findsNothing);
      expect(find.textContaining('Banda Uelo'), findsNothing);
    });

    testWidgets(
      'deep-link vazio não inventa Banda Uelo/240 (fixtures off)',
      (tester) async {
        expect(CfTempMocks.useMembershipActivationConfirmedFixtures, isFalse);

        final router = GoRouter(
          initialLocation: Pages.profileMembershipActivationConfirmedOf(
            artistName: '',
            pricePerMonth: 0,
          ),
          routes: [
            GoRoute(
              path: Pages.profileMembershipActivationConfirmed,
              builder: (context, state) =>
                  ProfileMembershipActivationConfirmedScreen(
                artistName: state.uri.queryParameters['artistName'] ?? '',
                pricePerMonth:
                    int.tryParse(
                      state.uri.queryParameters['pricePerMonth'] ?? '',
                    ) ??
                    0,
              ),
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

        expect(find.text('Oficialmente do bando!'), findsOneWidget);
        expect(find.textContaining('o artista'), findsWidgets);
        expect(find.text('100 /mês'), findsOneWidget);
        expect(find.textContaining('Banda Uelo'), findsNothing);
        expect(find.text('240 /mês'), findsNothing);
        expect(find.text('@bandauelo'), findsNothing);
      },
    );

    test(
      'flag CF-207 off; Assinar/hub memberships permanece off',
      () {
        expect(CfTempMocks.useMembershipFixtures, isFalse);
        expect(CfTempMocks.useMembershipActivationConfirmedFixtures, isFalse);
      },
    );
  });

  group('CF-207 edge — teclado / longo / fixtures / zero', () {
    testWidgets('nome longo não esconde Fechar nem quebra card', (
      tester,
    ) async {
      const longName =
          'Artista Com Nome Extremamente Longo Para Testar Overflow No Card De Membership';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileMembershipActivationConfirmedScreen(
            artistName: longName,
            artistHandle: '@handle_muito_longo_para_edge_case_qa',
            pricePerMonth: 9999,
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining(longName), findsWidgets);
      expect(find.text('9999 /mês'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handle sem @ ganha prefixo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const MembershipActivationConfirmedCard(
            artistName: 'Uelo',
            artistHandle: 'bandauelo',
            pricePerMonth: 240,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('@bandauelo'), findsOneWidget);
    });

    testWidgets('tela é apresentacional (Stateless) — reabrir não cobra', (
      tester,
    ) async {
      expect(
        ProfileMembershipActivationConfirmedScreen,
        equals(ProfileMembershipActivationConfirmedScreen),
      );
      const screen = ProfileMembershipActivationConfirmedScreen(
        artistName: 'Banda Uelo',
        pricePerMonth: 240,
      );
      expect(screen, isA<StatelessWidget>());

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: screen,
        ),
      );
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: screen,
        ),
      );
      await tester.pump();

      expect(find.text('Oficialmente do bando!'), findsOneWidget);
      expect(find.text('Assinar'), findsNothing);
    });

    test(
      'helper print permanece disponível para deep-link seeded (fixtures off)',
      () {
        expect(CfTempMocks.useMembershipActivationConfirmedFixtures, isFalse);
        expect(cfTempMockMembershipSummary.artistName, 'Banda Uelo');
        expect(cfTempMockMembershipSummary.pricePerMonth, 240);
        final seeded = Pages.profileMembershipActivationConfirmedOf(
          artistName: cfTempMockMembershipSummary.artistName,
          pricePerMonth: cfTempMockMembershipSummary.pricePerMonth,
          artistHandle: cfTempMockMembershipSummary.artistHandle,
        );
        expect(seeded, contains('artistName=Banda+Uelo'));
        expect(seeded, contains('pricePerMonth=240'));
        expect(seeded, contains('artistHandle'));
      },
    );
  });
}
