import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_manage_artist_summary.dart';
import 'package:crowdfans/components/profile/membership_manage_option_tile.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/membership.dart';
import 'package:crowdfans/screens/profile/profile_membership_manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('CF-205 green — sucesso / print', () {
    testWidgets(
      'print Marinhos: opções separadas; selecionar não confirma; Confirmar presente',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const ProfileMembershipManageScreen(
              artistId: 'artist-1',
              artistName: 'Marinhos',
              artistHandle: '@marinhos',
              pricePerMonth: 240,
              monthsLabel: '3 meses',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Gerenciar membership'), findsOneWidget);
        expect(find.text('Marinhos'), findsOneWidget);
        expect(find.text('@marinhos'), findsOneWidget);
        expect(find.text('240/mês'), findsOneWidget);
        expect(
          find.text('O que você quer fazer com esse membership?'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Seu vínculo atual está em 3 meses.'),
          findsOneWidget,
        );
        expect(find.text('Pausar membership'), findsOneWidget);
        expect(find.text('Cancelar membership'), findsOneWidget);
        expect(find.textContaining('interrompe a cobrança'), findsOneWidget);
        expect(find.textContaining('encerra a assinatura'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
        expect(find.byType(AppButton), findsOneWidget);
        expect(find.byType(MembershipManageArtistSummary), findsOneWidget);

        await tester.tap(find.text('Cancelar membership'));
        await tester.pump();

        // Selecionar só muda UI — Confirmar continua; não há diálogo de sucesso.
        expect(find.text('Confirmar'), findsOneWidget);
        expect(find.text('Membership'), findsNothing);
      },
    );

    test('helper print Marinhos 240 / 3 meses permanece para testes', () {
      expect(CfTempMocks.useMembershipManageFixtures, isFalse);
      expect(cfTempMockMembershipManage.artistName, 'Marinhos');
      expect(cfTempMockMembershipManage.artistHandle, '@marinhos');
      expect(cfTempMockMembershipManage.pricePerMonth, 240);
      expect(cfTempMockMembershipManage.monthsLabel, '3 meses');
    });
  });

  group('CF-205 red — bloqueio / inválido', () {
    testWidgets(
      'deep-link vazio sem TEMP: não inventa Marinhos/240; fallback Artista/100',
      (tester) async {
        expect(CfTempMocks.useMembershipManageFixtures, isFalse);

        final router = GoRouter(
          initialLocation: Pages.profileMembershipManageOf(
            artistId: 'mock',
            artistName: '',
            pricePerMonth: 0,
          ),
          routes: [
            GoRoute(
              path: Pages.profileMembershipManage,
              builder: (context, state) => ProfileMembershipManageScreen(
                artistId: state.uri.queryParameters['artistId'] ?? '',
                artistName: state.uri.queryParameters['artistName'] ?? '',
                artistHandle: state.uri.queryParameters['artistHandle'],
                pricePerMonth:
                    int.tryParse(
                      state.uri.queryParameters['pricePerMonth'] ?? '',
                    ) ??
                    0,
                monthsLabel: state.uri.queryParameters['monthsLabel'],
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

        expect(find.text('Marinhos'), findsNothing);
        expect(find.text('@marinhos'), findsNothing);
        expect(find.text('240/mês'), findsNothing);
        expect(find.text('Artista'), findsOneWidget);
        expect(find.text('100/mês'), findsOneWidget);
        expect(find.text('Pausar membership'), findsOneWidget);
        expect(find.text('Cancelar membership'), findsOneWidget);
      },
    );

    testWidgets('artistId vazio: Confirmar não navega para memberships', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/manage',
        routes: [
          GoRoute(
            path: '/manage',
            builder: (context, state) => const ProfileMembershipManageScreen(
              artistId: '   ',
              artistName: 'Marinhos',
              artistHandle: '@marinhos',
              pricePerMonth: 240,
              monthsLabel: '3 meses',
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

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('meus-memberships'), findsNothing);
      expect(find.text('Gerenciar membership'), findsOneWidget);
    });

    testWidgets('status paused ≠ cancelled; canCancel em pausada', (
      tester,
    ) async {
      const paused = MembershipCard(
        id: 'm1',
        artistId: 'a1',
        status: 'paused',
        statusLabel: 'Pausada',
      );
      const cancelled = MembershipCard(
        id: 'm2',
        artistId: 'a2',
        status: 'cancelled',
      );

      expect(paused.isPaused, isTrue);
      expect(paused.isCancelled, isFalse);
      expect(paused.isActiveStatus, isFalse);
      expect(paused.canCancel, isTrue);

      expect(cancelled.isPaused, isFalse);
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.canCancel, isFalse);
    });

    test('pause API path ≠ cancel; Assinar CF-206 fixtures off; manage demock', () {
      expect(
        Pages.profileMembershipManage,
        '/me/settings/memberships/manage',
      );
      expect(CfTempMocks.useMembershipFixtures, isFalse);
      expect(CfTempMocks.useMembershipManageFixtures, isFalse);
      expect(
        cfTempMockMembershipManage.artistName,
        isNot(cfTempMockMembershipSummary.artistName),
      );
    });
  });

  group('CF-205 edge — texto longo / meses / handle', () {
    test('membershipManageMonthsLabel corta consecutivos', () {
      expect(
        membershipManageMonthsLabel('3 meses consecutivos'),
        '3 meses',
      );
      expect(membershipManageMonthsLabel('3 meses'), '3 meses');
      expect(membershipManageMonthsLabel(null), '');
      expect(membershipManageMonthsLabel('  '), '');
    });

    testWidgets('nome longo e handle sem @; opções Pausar/Cancelar intactas', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileMembershipManageScreen(
            artistId: 'artist-long',
            artistName:
                'Banda Super Extra Longa Com Nome Que Não Cabe Em Uma Linha',
            artistHandle: 'bandalonga',
            pricePerMonth: 100,
            monthsLabel: '12 meses consecutivos',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          'Banda Super Extra Longa Com Nome Que Não Cabe Em Uma Linha',
        ),
        findsOneWidget,
      );
      expect(find.text('@bandalonga'), findsOneWidget);
      expect(find.text('100/mês'), findsOneWidget);
      expect(
        find.textContaining('Seu vínculo atual está em 12 meses.'),
        findsOneWidget,
      );
      expect(find.textContaining('consecutivos'), findsNothing);
      expect(find.text('Pausar membership'), findsOneWidget);
      expect(find.text('Cancelar membership'), findsOneWidget);

      await tester.tap(find.text('Pausar membership'));
      await tester.pump();
      expect(find.text('Confirmar'), findsOneWidget);
    });

    testWidgets('selecionar Pause/Cancel só troca selected; tiles separados', (
      tester,
    ) async {
      var selected = MembershipManageAction.pause;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    MembershipManageOptionTile(
                      action: MembershipManageAction.pause,
                      selected: selected == MembershipManageAction.pause,
                      onSelected: (action) => setState(() => selected = action),
                    ),
                    MembershipManageOptionTile(
                      action: MembershipManageAction.cancel,
                      selected: selected == MembershipManageAction.cancel,
                      onSelected: (action) => setState(() => selected = action),
                    ),
                    Text('selecionado: ${selected.name}'),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('selecionado: pause'), findsOneWidget);
      await tester.tap(find.text('Cancelar membership'));
      await tester.pump();
      expect(find.text('selecionado: cancel'), findsOneWidget);
      await tester.tap(find.text('Pausar membership'));
      await tester.pump();
      expect(find.text('selecionado: pause'), findsOneWidget);
    });
  });
}
