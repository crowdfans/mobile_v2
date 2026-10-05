import 'package:crowdfans/components/fan_club/fan_club_moderation_card.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_search_field.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_section_header.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_tab_bar.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-199 fixtures on + contagens Contestações 2 / Avisos 2 / Expulsos 1', () {
    expect(CfTempMocks.useModerationPanelFixtures, isTrue);
    expect(Cf199ModerationPanelFixtures.appeals(), hasLength(2));
    expect(Cf199ModerationPanelFixtures.strikes(), hasLength(2));
    expect(Cf199ModerationPanelFixtures.expulsions(), hasLength(1));
  });

  test('CF-199 rota do painel', () {
    expect(
      Pages.fanClubModerationOf(artistId: 'artist-1', name: 'Demo'),
      contains(Pages.fanClubModeration),
    );
  });

  testWidgets(
    'CF-199 vazio: header + Pedidos para voltar badge 0 sem ProfileState',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ProfileScreenHeader(
                    title: 'Painel de moderação',
                    onBack: () {},
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: const [
                        FanClubModerationSearchField(
                          initialValue: '',
                          onChanged: _noop,
                        ),
                        SizedBox(height: 14),
                        FanClubModerationTabBar(
                          selectedId: 'contestacoes',
                          contestationCount: 0,
                          warningCount: 0,
                          expulsionCount: 0,
                          onSelected: _noopString,
                        ),
                        SizedBox(height: 18),
                        FanClubModerationSectionHeader(
                          title: 'Pedidos para voltar',
                          count: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Painel de moderação'), findsOneWidget);
      expect(find.text('Contestações 0'), findsOneWidget);
      expect(find.text('Avisos 0'), findsOneWidget);
      expect(find.text('Expulsos 0'), findsOneWidget);
      expect(find.text('Pedidos para voltar'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(ProfileState), findsNothing);
      expect(find.byType(FanClubModerationCard), findsNothing);
    },
  );

  testWidgets(
    'CF-199 fila: Anna Lu / Vic Melo, Defesa enviada, Aceitar/Recusar',
    (tester) async {
      final appeals = Cf199ModerationPanelFixtures.appeals();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                children: [
                  FanClubModerationTabBar(
                    selectedId: 'contestacoes',
                    contestationCount: appeals.length,
                    warningCount: 2,
                    expulsionCount: 1,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 18),
                  FanClubModerationSectionHeader(
                    title: 'Pedidos para voltar',
                    count: appeals.length,
                  ),
                  const SizedBox(height: 12),
                  for (final appeal in appeals) ...[
                    FanClubModerationCard(
                      title: appeal.displayName,
                      subtitle: 'fan/${appeal.handle}',
                      photoUrl: appeal.photoUrl,
                      statusLabel: 'Defesa enviada',
                      body: appeal.defense,
                      onApprove: () {},
                      onReject: () {},
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Contestações 2'), findsOneWidget);
      expect(find.text('Avisos 2'), findsOneWidget);
      expect(find.text('Expulsos 1'), findsOneWidget);
      expect(find.text('Pedidos para voltar'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('Anna Lu'), findsOneWidget);
      expect(find.text('Vic Melo'), findsOneWidget);
      expect(find.text('fan/annalu'), findsOneWidget);
      expect(find.text('fan/vicmelo'), findsOneWidget);
      expect(find.text('Defesa enviada'), findsNWidgets(2));
      expect(find.text('Aceitar'), findsNWidgets(2));
      expect(find.text('Recusar'), findsNWidgets(2));
      expect(
        find.textContaining('apaguei as publicações'),
        findsOneWidget,
      );
      expect(
        find.textContaining('segui as orientações da moderação'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CF-199 Aceitar em fixture remove o caso e atualiza contagem',
    (tester) async {
      var appeals = List<FanClubAppeal>.from(
        Cf199ModerationPanelFixtures.appeals(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    FanClubModerationTabBar(
                      selectedId: 'contestacoes',
                      contestationCount: appeals.length,
                      warningCount: 2,
                      expulsionCount: 1,
                      onSelected: (_) {},
                    ),
                    FanClubModerationSectionHeader(
                      title: 'Pedidos para voltar',
                      count: appeals.length,
                    ),
                    for (final appeal in appeals)
                      FanClubModerationCard(
                        title: appeal.displayName,
                        subtitle: 'fan/${appeal.handle}',
                        statusLabel: 'Defesa enviada',
                        body: appeal.defense,
                        onApprove: () {
                          setState(() {
                            appeals = [
                              for (final item in appeals)
                                if (item.appealId != appeal.appealId) item,
                            ];
                          });
                        },
                        onReject: () {},
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Contestações 2'), findsOneWidget);
      expect(find.text('Anna Lu'), findsOneWidget);

      await tester.tap(find.text('Aceitar').first);
      await tester.pump();

      expect(find.text('Contestações 1'), findsOneWidget);
      expect(find.text('Anna Lu'), findsNothing);
      expect(find.text('Vic Melo'), findsOneWidget);
      expect(find.text('Aceitar'), findsOneWidget);
    },
  );
}

void _noop(String value) {}

void _noopString(String value) {}
