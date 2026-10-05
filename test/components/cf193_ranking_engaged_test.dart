import 'package:crowdfans/components/search/search_artist_rank_row.dart';
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
  // --- GREEN: print / sucesso (métrica + período + layout) ---

  test('CF-193 green: fixtures Engajados ordenado por interações (7d)', () {
    expect(CfTempMocks.useRankingFixtures, isTrue);
    final rows = cfTempMockRankingArtists(kind: 'engaged', limit: 8);
    expect(rows.length, 8);

    // Rank = ordem das interações (não o Top 500 membros).
    expect(rows.map((r) => r.name).toList(), [
      'Mayra',
      'Marinhos',
      'Banda Uelo',
      'Ludmilla',
      'Carol Biazin',
      'TINN',
      'Enzo Lima',
      'Anitta',
    ]);
    expect(rows.map((r) => r.rank).toList(), [1, 2, 3, 4, 5, 6, 7, 8]);
    expect(rows.map((r) => r.membersLabel).toList(), [
      '12 interações (7d)',
      '9 interações (7d)',
      '7 interações (7d)',
      '4 interações (7d)',
      '3 interações (7d)',
      '2 interações (7d)',
      '1 interação (7d)',
      '0 interações (7d)',
    ]);
    for (final row in rows) {
      expect(row.membersLabel.toLowerCase(), isNot(contains('posts')));
      expect(row.membersLabel.toLowerCase(), isNot(contains('24')));
      expect(row.membersLabel, contains('(7d)'));
    }
  });

  test('CF-193 green: chrome = interações 7d (título/subtítulo/métrica)', () {
    expect(rankingLeadForKind('engaged'), 'Top 100');
    expect(rankingQualifierForKind('engaged'), 'Engajados');
    expect(
      rankingSubtitleForKind('engaged'),
      'Artistas com mais interações nos últimos 7 dias',
    );
    expect(rankingMetricHintForKind('engaged'), 'interações (7d)');
    expect(rankingSortLabelForKind('engaged'), 'Ordenar por:');
    expect(rankingLimitForKind('engaged'), 100);
  });

  testWidgets('CF-193 green: tela Top 100 · Engajados + #1 = Mayra/12', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SearchRankingScreen(kind: 'engaged')),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Top 100') &&
            w.text.toPlainText().contains('Engajados'),
      ),
      findsOneWidget,
    );
    expect(find.text('Ordenar por:'), findsOneWidget);
    expect(find.text('Crescente'), findsOneWidget);
    expect(find.text('Decrescente'), findsOneWidget);

    // Lista: #1 = mais interações (Mayra / 12).
    expect(find.text('Mayra'), findsOneWidget);
    expect(find.text('12 interações (7d)'), findsOneWidget);

    // Layout print: # à esquerda do avatar.
    final badge = tester.getTopLeft(find.text('#1'));
    final clip = tester.getTopLeft(find.byType(ClipRRect).first);
    expect(badge.dx, lessThan(clip.dx));

    // Sem subtítulo visual (chrome CF-189); métrica no Semantics do título.
    expect(
      find.text('Artistas com mais interações nos últimos 7 dias'),
      findsNothing,
    );
    final semantics = tester.getSemantics(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Top 100') &&
            w.text.toPlainText().contains('Engajados'),
      ),
    );
    expect(semantics.label, contains('interações'));
    expect(semantics.label, contains('7 dias'));
  });

  // --- RED: não confundir com Top Ativos / Seguidores / Brasil ---

  test('CF-193 red: chrome Engajados ≠ Ativos ≠ Brasil/Seguidores', () {
    expect(rankingQualifierForKind('engaged'), isNot('Ativos'));
    expect(rankingQualifierForKind('engaged'), isNot('Brasil'));
    expect(rankingLeadForKind('engaged'), isNot(rankingLeadForKind('active')));
    expect(
      rankingSubtitleForKind('engaged').toLowerCase(),
      isNot(contains('posts')),
    );
    expect(
      rankingSubtitleForKind('engaged').toLowerCase(),
      isNot(contains('24 horas')),
    );
    expect(
      rankingSubtitleForKind('engaged').toLowerCase(),
      isNot(contains('seguidores')),
    );
    expect(rankingMetricHintForKind('engaged'), isNot('posts (7d)'));
    expect(rankingMetricHintForKind('engaged'), isNot('membros'));
    expect(
      rankingSortLabelForKind('engaged'),
      isNot(contains('postagens')),
    );

    // Ativos / fan-clubs mantêm copy próprio (regressão cruzada).
    expect(rankingQualifierForKind('active'), 'Ativos');
    expect(rankingSubtitleForKind('active'), contains('posts'));
    expect(rankingMetricHintForKind('active'), 'posts (7d)');
    expect(rankingQualifierForKind('fan-clubs'), 'Brasil');
    expect(rankingSortLabelForKind('fan-clubs'), 'Ordenar postagens por:');
  });

  testWidgets('CF-193 red: tela Engajados sem copy de Ativos/Brasil/24h', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SearchRankingScreen(kind: 'engaged')),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Brasil'), findsNothing);
    expect(find.textContaining('Ativos'), findsNothing);
    expect(find.text('Ordenar postagens por:'), findsNothing);
    expect(
      find.text('Artistas com mais posts nas últimas 24 horas'),
      findsNothing,
    );
    expect(find.textContaining('posts (7d)'), findsNothing);
    expect(find.textContaining('membros'), findsNothing);
  });

  // --- EDGE: zero engajamento, nomes longos, lista vazia, fixtures ---

  test('CF-193 edge: zero engajamento (Anitta) e singular 1 interação', () {
    final rows = cfTempMockRankingArtists(kind: 'engaged', limit: 8);
    final zero = rows.lastWhere((r) => r.name == 'Anitta');
    expect(zero.membersLabel, '0 interações (7d)');
    expect(zero.memberCount, 0);
    expect(zero.rank, 8);

    final one = rows.firstWhere((r) => r.name == 'Enzo Lima');
    expect(one.membersLabel, '1 interação (7d)');
    expect(one.membersLabel, isNot(contains('interações')));
  });

  testWidgets('CF-193 edge: nome longo elide sem overflow na linha', (
    tester,
  ) async {
    const longName =
        'Artista Super Engajado Com Nome Extremamente Longo Para Validar Ellipsis';
    await tester.pumpWidget(
      _wrap(
        SearchArtistRankRow(
          artist: const ArtistSearchItem(
            id: 'cf193-long',
            name: longName,
            handle: '@longo',
            avatarUri: '',
            memberCount: 0,
            membersLabel: '0 interações (7d)',
            rank: 99,
            trend: 'neutral',
          ),
          position: 99,
          metricHint: rankingMetricHintForKind('engaged'),
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
    expect(find.text('0 interações (7d)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CF-193 edge: lista vazia mostra empty state distinto', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: ListView(
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
      ),
    );
    await tester.pump();

    expect(find.text('Nenhum artista neste ranking ainda.'), findsOneWidget);
    expect(find.text('Mayra'), findsNothing);
    expect(find.text('12 interações (7d)'), findsNothing);
  });

  testWidgets('CF-193 edge: erro de carga distinto do empty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Não foi possível carregar o ranking.'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Não foi possível carregar o ranking.'), findsOneWidget);
    expect(find.text('Nenhum artista neste ranking ainda.'), findsNothing);
  });

  test('CF-193 edge: fixtures ranking ON até snapshot histórico', () {
    // Flag const: Engajados ainda depende de fixtures (tendência/densidade).
    // Off só quando BACKEND_TODO ranking + dados reais ≈ print.
    expect(CfTempMocks.useRankingFixtures, isTrue);
    // Chrome helpers continuam corretos sem depender do flag (API path).
    expect(rankingMetricHintForKind('engaged'), 'interações (7d)');
    expect(rankingLimitForKind('engaged'), 100);
    // Fan-clubs fixtures intactas (CF-189) — Engajados só reordena engaged.
    final fanClubs = cfTempMockRankingArtists(kind: 'fan-clubs', limit: 3);
    expect(fanClubs.first.name, 'Ludmilla');
    expect(fanClubs.first.membersLabel, '512 mil membros');
  });
}
