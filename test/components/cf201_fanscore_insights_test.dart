import 'package:crowdfans/components/profile/fan_score_artist_card.dart';
import 'package:crowdfans/components/profile/fan_score_cycle_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:crowdfans/screens/profile/fan_score_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _wrapFanScore({
  required String handle,
  FanScoreData? data,
  String? loadError,
}) {
  final router = GoRouter(
    initialLocation: '/fan-score',
    routes: [
      GoRoute(
        path: '/fan-score',
        builder: (context, state) => FanScoreScreen(
          fanHandle: handle,
          dataForTest: data,
          loadErrorForTest: loadError,
        ),
      ),
      GoRoute(
        path: '/me/settings/fan-score/how-it-works',
        builder: (context, state) => const Scaffold(
          body: Text('Como funciona stub'),
        ),
      ),
    ],
  );
  return MaterialApp.router(
    theme: buildCrowdFansTheme(Brightness.light),
    routerConfig: router,
  );
}

void main() {
  final mock = cfTempMockFanScoreData();
  final entry = mock.entries.first;

  test('CF-201 demock: fixtures off; helper permanece p/ testes', () {
    expect(CfTempMocks.useFanScoreFixtures, isFalse);
    expect(kUseCfTempMocks, isTrue);
    expect(mock.entries, hasLength(3));
    expect(mock.entries.first.tier.label, 'Ultimate Fan');
    expect(mock.entries.first.breakdown.fanClubPosts, 10);
    expect(mock.entries.first.breakdown.hasMembership, isTrue);
  });

  testWidgets(
    'CF-201 green: insights expandem no mesmo card; artista permanece',
    (tester) async {
      var expanded = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: FanScoreArtistCard(
                  entry: entry,
                  expanded: expanded,
                  onToggleInsights: () => setState(() => expanded = !expanded),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kheper'), findsOneWidget);
      expect(find.text('1.000'), findsOneWidget);
      expect(find.text('+4%'), findsOneWidget);
      expect(find.text('#7'), findsOneWidget);
      expect(find.text('ULTIMATE FAN'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Posts FC'), findsNothing);

      final delta = tester.getTopLeft(find.text('+4%'));
      final rank = tester.getTopLeft(find.text('#7'));
      expect(delta.dx, lessThan(rank.dx));

      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();

      expect(find.text('Kheper'), findsOneWidget);
      expect(find.text('1.000'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Posts FC'), findsOneWidget);
      expect(find.text('Cartas'), findsOneWidget);
      expect(find.text('Coment.'), findsOneWidget);
      expect(find.text('Upvotes'), findsOneWidget);
      expect(find.text('Lives'), findsOneWidget);
      expect(find.text('Doações'), findsOneWidget);
      expect(find.text('Membership'), findsOneWidget);
      expect(find.text('10'), findsWidgets);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);

      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();

      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Posts FC'), findsNothing);
      expect(find.text('Kheper'), findsOneWidget);
    },
  );

  testWidgets(
    'CF-201 green: tela com ciclo + cards Super; Insights no mesmo card',
    (tester) async {
      await tester.pumpWidget(
        _wrapFanScore(handle: 'demo', data: mock),
      );
      await tester.pumpAndSettle();

      expect(find.text('FanScore'), findsOneWidget);
      expect(find.text('Pontuação vigente: Agosto 2026'), findsOneWidget);
      expect(
        find.textContaining('segunda-feira, 31/08/2026 às 23:59'),
        findsOneWidget,
      );
      expect(find.text('Kheper'), findsOneWidget);
      expect(find.text('Marinhos'), findsOneWidget);
      expect(find.text('ULTIMATE FAN'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Posts FC'), findsOneWidget);
      expect(find.text('Buscar artista'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Banda Uelo'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Banda Uelo'), findsOneWidget);
      expect(find.text('SUPER FAN'), findsWidgets);
      expect(find.text('Insights'), findsWidgets);
    },
  );

  testWidgets('CF-201 red: lista vazia não fica em branco', (tester) async {
    await tester.pumpWidget(
      _wrapFanScore(
        handle: 'demo',
        data: const FanScoreData(
          cycleDetails: FanScoreCycleDetails(
            periodLabel: 'Outubro 2026',
            endLabel: 'sábado, 31/10/2026 às 23:59',
          ),
          entries: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FanScore'), findsOneWidget);
    expect(find.text('Pontuação vigente: Outubro 2026'), findsOneWidget);
    expect(
      find.textContaining('Siga ou assine artistas para começar a pontuar'),
      findsOneWidget,
    );
    expect(find.text('Kheper'), findsNothing);
  });

  testWidgets('CF-201 red: erro de carga com retry', (tester) async {
    await tester.pumpWidget(
      _wrapFanScore(
        handle: 'demo',
        loadError: 'Não foi possível carregar o Fan Score.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar o Fan Score.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Kheper'), findsNothing);
  });

  testWidgets('CF-201 edge: busca sem match + fixtures off', (tester) async {
    await tester.pumpWidget(
      _wrapFanScore(handle: 'demo', data: mock),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz-inexistente');
    await tester.pumpAndSettle();

    expect(
      find.text('Nenhum artista encontrado para essa busca.'),
      findsOneWidget,
    );
    expect(find.text('Kheper'), findsNothing);
    expect(CfTempMocks.useFanScoreFixtures, isFalse);
  });

  testWidgets(
    'CF-201: ciclo vigente + cards Super recolhidos do print (componentes)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                FanScoreCycleCard(details: mock.cycleDetails!),
                for (final e in mock.entries)
                  FanScoreArtistCard(
                    entry: e,
                    expanded: e.artistId == entry.artistId,
                    onToggleInsights: () {},
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pontuação vigente: Agosto 2026'), findsOneWidget);
      expect(
        find.textContaining('segunda-feira, 31/08/2026 às 23:59'),
        findsOneWidget,
      );
      expect(find.text('Marinhos'), findsOneWidget);
      expect(find.text('Banda Uelo'), findsOneWidget);
      expect(find.text('SUPER FAN'), findsNWidgets(2));
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Insights'), findsNWidgets(2));
      expect(find.text('Posts FC'), findsOneWidget);
    },
  );
}
