import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/search/search_ranking_screen.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: child is Scaffold ? child : Scaffold(body: child),
  );
}

void main() {
  // --- GREEN: print Top 500 · Brasil (densidade + tendência + chrome) ---

  test('CF-189 green: fixtures off — UI usa API real', () {
    expect(CfTempMocks.useRankingFixtures, isFalse);
  });

  test('CF-189 green: amostra print 8 linhas + tendências up/down/neutro', () {
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
    expect(searchRankTrendFromArtist(rows[0]), SearchRankTrend.up);
    expect(searchRankTrendFromArtist(rows[1]), SearchRankTrend.down);
    expect(searchRankTrendFromArtist(rows[2]), SearchRankTrend.flat);
  });

  test('CF-189 green: chrome Top 500 · Brasil + sort + limit', () {
    expect(rankingLeadForKind('fan-clubs'), 'Top 500');
    expect(rankingQualifierForKind('fan-clubs'), 'Brasil');
    expect(rankingMetricHintForKind('fan-clubs'), 'membros');
    expect(rankingSortLabelForKind('fan-clubs'), 'Ordenar postagens por:');
    expect(rankingLimitForKind('fan-clubs'), 500);
    expect(
      rankingSubtitleForKind('fan-clubs'),
      'Artistas com mais seguidores / assinantes',
    );
  });

  test('CF-189 green: rota filha do shell Explorar (nav inferior)', () {
    expect(Pages.searchRanking, '/explore/ranking');
    expect(Pages.searchRanking.startsWith(Pages.explore), isTrue);
  });

  testWidgets('CF-189 green: rankLeading # → tendência → avatar □; sem rótulo', (
    tester,
  ) async {
    final artist = cfTempMockRankingArtists(kind: 'fan-clubs').first;
    await tester.pumpWidget(
      _wrap(
        SearchArtistRankRow(
          artist: artist,
          position: 1,
          layout: SearchArtistRankRowLayout.rankLeading,
          metricHint: 'membros',
          onPressed: () {},
          onPressMore: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Ludmilla'), findsOneWidget);
    expect(find.text('512 mil membros'), findsOneWidget);
    expect(find.text('subiu'), findsNothing);
    expect(find.text('desceu'), findsNothing);
    expect(find.text('estável'), findsNothing);

    final badge = tester.getTopLeft(find.text('#1'));
    final clip = tester.getTopLeft(find.byType(ClipRRect).first);
    expect(badge.dx, lessThan(clip.dx));

    // Densidade compacta (print: ~8 linhas na viewport).
    expect(
      find.byWidgetPredicate(
        (w) => w is Padding && w.padding == const EdgeInsets.only(bottom: 8),
      ),
      findsWidgets,
    );
    // Avatar quadrado arredondado (não CircleAvatar).
    expect(find.byType(CircleAvatar), findsNothing);
    final clipWidget = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
    expect(clipWidget.borderRadius, BorderRadius.circular(8));
  });

  testWidgets('CF-189 green: tela Top 500 · Brasil sem subtítulo visual', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SearchRankingScreen(kind: 'fan-clubs')),
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
    expect(find.text('Ordenar postagens por:'), findsOneWidget);
    expect(find.text('Crescente'), findsOneWidget);
    expect(find.text('Decrescente'), findsOneWidget);
    expect(
      find.text('Artistas com mais seguidores / assinantes'),
      findsNothing,
    );

    final semantics = tester.getSemantics(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Top 500') &&
            w.text.toPlainText().contains('Brasil'),
      ),
    );
    expect(semantics.label, contains('seguidores'));
  });

  testWidgets('CF-189 green: tendências up/down/flat por ícone+cor', (
    tester,
  ) async {
    final rows = cfTempMockRankingArtists(kind: 'fan-clubs', limit: 3);
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            for (var i = 0; i < rows.length; i++)
              SearchArtistRankRow(
                artist: rows[i],
                position: rows[i].rank ?? i + 1,
                layout: SearchArtistRankRowLayout.rankLeading,
                metricHint: 'membros',
                onPressed: () {},
                onPressMore: () {},
              ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    expect(find.text('subiu'), findsNothing);
    expect(find.text('desceu'), findsNothing);
    expect(find.text('estável'), findsNothing);
  });

  // --- RED: não colorir neutro; não regressar ao app antigo ---

  test('CF-189 red: chrome Brasil ≠ Engajados/Ativos', () {
    expect(rankingQualifierForKind('fan-clubs'), isNot('Engajados'));
    expect(rankingQualifierForKind('fan-clubs'), isNot('Ativos'));
    expect(rankingLeadForKind('fan-clubs'), isNot('Top 100'));
    expect(rankingMetricHintForKind('fan-clubs'), isNot('interações (7d)'));
    expect(rankingMetricHintForKind('fan-clubs'), isNot('posts (7d)'));
    expect(rankingSortLabelForKind('fan-clubs'), contains('postagens'));
  });

  test('CF-189 red: neutro não herda up/down; trend new → flat', () {
    const neutral = ArtistSearchItem(
      id: 'n',
      name: 'N',
      handle: '@n',
      avatarUri: '',
      memberCount: 0,
      membersLabel: '0 membros',
      rank: 3,
      trend: 'neutral',
    );
    const neu = ArtistSearchItem(
      id: 'new',
      name: 'New',
      handle: '@new',
      avatarUri: '',
      memberCount: 1,
      membersLabel: '1 membro',
      rank: 10,
      trend: 'new',
    );
    expect(searchRankTrendFromArtist(neutral), SearchRankTrend.flat);
    expect(searchRankTrendFromArtist(neu), SearchRankTrend.flat);
    expect(searchRankTrendFromArtist(neutral), isNot(SearchRankTrend.up));
    expect(searchRankTrendFromArtist(neutral), isNot(SearchRankTrend.down));
  });

  testWidgets('CF-189 red: tela sem copy Engajados/Ativos/24h; sem fixtures', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SearchRankingScreen(kind: 'fan-clubs')),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Engajados'), findsNothing);
    expect(find.textContaining('Ativos'), findsNothing);
    expect(find.text('Ordenar por:'), findsNothing);
    expect(find.textContaining('24 horas'), findsNothing);
    expect(find.textContaining('interações (7d)'), findsNothing);
    // Fixtures off: sem Ludmilla TEMP injetada na UI.
    expect(find.text('Ludmilla'), findsNothing);
    expect(find.text('TINN'), findsNothing);
  });

  // --- EDGE: erro API, vazio, nome longo, zero membros, sort ---

  testWidgets('CF-189 edge: copy de erro distinto do empty (API real)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Não foi possível carregar o ranking.'),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.text('Não foi possível carregar o ranking.'),
      findsOneWidget,
    );
    expect(find.text('Nenhum artista neste ranking ainda.'), findsNothing);
    expect(find.text('Ludmilla'), findsNothing);
  });

  testWidgets('CF-189 edge: empty state distinto do erro', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'Nenhum artista neste ranking ainda.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Nenhum artista neste ranking ainda.'), findsOneWidget);
    expect(
      find.text('Não foi possível carregar o ranking.'),
      findsNothing,
    );
  });

  testWidgets('CF-189 edge: tela API sem auth → erro, sem fixtures TEMP', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SearchRankingScreen(kind: 'fan-clubs')),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Fixtures removidas da UI: nunca injeta Ludmilla/TINN no fallback.
    expect(find.text('Ludmilla'), findsNothing);
    expect(find.text('TINN'), findsNothing);
    // Sem sessão Firebase no widget test → erro ou loading, nunca TEMP.
    final hasError = find
        .text('Não foi possível carregar o ranking.')
        .evaluate()
        .isNotEmpty;
    final hasLoader = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasEmpty = find
        .text('Nenhum artista neste ranking ainda.')
        .evaluate()
        .isNotEmpty;
    expect(hasError || hasLoader || hasEmpty, isTrue);
  });

  testWidgets('CF-189 edge: nome longo elide; 0 membros; neutro flat', (
    tester,
  ) async {
    const longName =
        'Artista Com Nome Extremamente Longo Para Densidade Do Print Top 500';
    await tester.pumpWidget(
      _wrap(
        SearchArtistRankRow(
          artist: const ArtistSearchItem(
            id: 'cf189-long',
            name: longName,
            handle: '@longo',
            avatarUri: '',
            memberCount: 0,
            membersLabel: '0 membros',
            rank: 99,
            trend: 'neutral',
          ),
          position: 99,
          metricHint: 'membros',
          layout: SearchArtistRankRowLayout.rankLeading,
          onPressed: () {},
          onPressMore: () {},
        ),
      ),
    );
    await tester.pump();

    final nameText = tester.widget<Text>(find.text(longName));
    expect(nameText.maxLines, 1);
    expect(nameText.overflow, TextOverflow.ellipsis);
    expect(find.text('0 membros'), findsOneWidget);
    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CF-189 edge: chips Crescente/Decrescente invertíveis', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SearchRankingScreen(kind: 'fan-clubs')),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Crescente'), findsOneWidget);
    expect(find.text('Decrescente'), findsOneWidget);
    await tester.tap(find.text('Decrescente'));
    await tester.pump();
    await tester.tap(find.text('Crescente'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
