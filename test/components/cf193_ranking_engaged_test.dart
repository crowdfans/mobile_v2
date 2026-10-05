import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/search/search_ranking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-193 fixtures: Engajados ordenado por interações (7d)', () {
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

  test('CF-193 chrome: Engajados = interações 7d (não posts/24h)', () {
    expect(rankingLeadForKind('engaged'), 'Top 100');
    expect(rankingQualifierForKind('engaged'), 'Engajados');
    expect(rankingQualifierForKind('engaged'), isNot('Brasil'));
    expect(
      rankingSubtitleForKind('engaged'),
      'Artistas com mais interações nos últimos 7 dias',
    );
    expect(
      rankingSubtitleForKind('engaged').toLowerCase(),
      isNot(contains('24 horas')),
    );
    expect(
      rankingSubtitleForKind('engaged').toLowerCase(),
      isNot(contains('posts')),
    );
    expect(rankingMetricHintForKind('engaged'), 'interações (7d)');
    expect(rankingSortLabelForKind('engaged'), 'Ordenar por:');
    expect(
      rankingSortLabelForKind('engaged'),
      isNot(contains('postagens')),
    );
    // CF-189 print: Top 500 mantém o rótulo do mock.
    expect(rankingSortLabelForKind('fan-clubs'), 'Ordenar postagens por:');
  });

  testWidgets('CF-193 tela: Top 100 · Engajados + métrica alinhada', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const SearchRankingScreen(kind: 'engaged'),
      ),
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
    expect(find.textContaining('Brasil'), findsNothing);
    expect(find.text('Ordenar por:'), findsOneWidget);
    expect(find.text('Ordenar postagens por:'), findsNothing);
    expect(find.text('Artistas com mais posts nas últimas 24 horas'), findsNothing);
    expect(find.text('Crescente'), findsOneWidget);
    expect(find.text('Decrescente'), findsOneWidget);

    // Lista: #1 = mais interações (Mayra / 12).
    expect(find.text('Mayra'), findsOneWidget);
    expect(find.text('12 interações (7d)'), findsOneWidget);
    expect(find.text('Anitta'), findsOneWidget);
    expect(find.text('0 interações (7d)'), findsOneWidget);

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
}
