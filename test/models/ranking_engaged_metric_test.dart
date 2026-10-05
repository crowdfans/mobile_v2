import 'package:crowdfans/screens/search/search_ranking_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Top 100 Engajados usa interações 7d em título e descrição', () {
    final subtitle = rankingSubtitleForKind('engaged');
    expect(subtitle.toLowerCase(), contains('interações'));
    expect(subtitle, contains('7 dias'));
    expect(subtitle.toLowerCase(), isNot(contains('24 horas')));
    expect(subtitle.toLowerCase(), isNot(contains('posts')));
    expect(rankingQualifierForKind('engaged'), 'Engajados');
    expect(rankingMetricHintForKind('engaged'), 'interações (7d)');
    expect(rankingSortLabelForKind('engaged'), 'Ordenar por:');
  });
}
