import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/search/search_ranking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-189 amostra print Top 500 Brasil (8 linhas + tendências)', () {
    expect(CfTempMocks.useRankingFixtures, isFalse); // CF-268
    final rows = cfTempMockRankingArtists(kind: 'fan-clubs', limit: 8);
    expect(rows.length, 8);
    expect(rows.map((r) => r.name).toList(), [
      'Ludmilla',
      'Anitta',
      'Mayra',
      'Banda Uelo',
      'Carol Biazin',
      'Marinhos',
      'Enzo Lima',
      'TINN',
    ]);
    expect(rows.map((r) => r.trend).toList(), [
      'up',
      'down',
      'neutral',
      'up',
      'down',
      'neutral',
      'down',
      'up',
    ]);
    expect(rows[0].membersLabel, '512 mil membros');
    expect(rows[5].membersLabel, '537 membros');
    expect(searchRankTrendFromArtist(rows[2]), SearchRankTrend.flat);
    expect(searchRankTrendFromArtist(rows[1]), SearchRankTrend.down);
    expect(searchRankTrendFromArtist(rows[0]), SearchRankTrend.up);
  });

  testWidgets('CF-189: rankLeading # → tendência → avatar; sem rótulo de cor', (
    tester,
  ) async {
    final artist = cfTempMockRankingArtists(kind: 'fan-clubs').first;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SearchArtistRankRow(
            artist: artist,
            position: 1,
            layout: SearchArtistRankRowLayout.rankLeading,
            metricHint: 'membros',
            onPressed: () {},
            onPressMore: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Ludmilla'), findsOneWidget);
    expect(find.text('512 mil membros'), findsOneWidget);
    expect(find.text('subiu'), findsNothing);
    expect(find.text('estável'), findsNothing);

    final badge = tester.getTopLeft(find.text('#1'));
    final clip = tester.getTopLeft(find.byType(ClipRRect).first);
    expect(badge.dx, lessThan(clip.dx));
  });

  testWidgets('CF-189 tela: título Top 500 · Brasil sem subtítulo visual', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const SearchRankingScreen(kind: 'fan-clubs'),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Top 500') &&
            w.text.toPlainText().contains('Brasil'),
      ),
      findsOneWidget,
    );
    expect(find.text('Crescente'), findsOneWidget);
    expect(find.text('Decrescente'), findsOneWidget);
    expect(
      find.text('Artistas com mais seguidores / assinantes'),
      findsNothing,
    );
    // Fixtures off (CF-268): lista vem da API — não assertar Ludmilla TEMP.
  });
}
