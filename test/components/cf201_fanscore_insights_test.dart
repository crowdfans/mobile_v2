import 'package:crowdfans/components/profile/fan_score_artist_card.dart';
import 'package:crowdfans/components/profile/fan_score_cycle_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mock = cfTempMockFanScoreData();
  final entry = mock.entries.first;

  testWidgets(
    'CF-201: insights expandem no mesmo card; artista permanece',
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

      // Print: círculo de tendência fica à esquerda do #rank.
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
    'CF-201: ciclo vigente + cards Super recolhidos do print',
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

  test('CF-201: fixtures TEMP ligados até API = print', () {
    expect(CfTempMocks.useFanScoreFixtures, isTrue);
    expect(kUseCfTempMocks, isTrue);
    expect(mock.entries, hasLength(3));
    expect(mock.entries.first.tier.label, 'Ultimate Fan');
    expect(mock.entries.first.breakdown.fanClubPosts, 10);
    expect(mock.entries.first.breakdown.hasMembership, isTrue);
  });
}
