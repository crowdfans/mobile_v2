import 'package:flutter_test/flutter_test.dart';

String rankingSubtitleForKind(String kind) {
  return switch (kind) {
    'active' => 'Artistas com mais posts nos últimos 7 dias',
    'engaged' => 'Artistas com mais interações nos últimos 7 dias',
    _ => 'Artistas com mais seguidores / assinantes',
  };
}

void main() {
  test('Top 100 Engajados usa interações 7d em título e descrição', () {
    final subtitle = rankingSubtitleForKind('engaged');
    expect(subtitle.toLowerCase(), contains('interações'));
    expect(subtitle, contains('7 dias'));
    expect(subtitle.toLowerCase(), isNot(contains('24 horas')));
    expect(subtitle.toLowerCase(), isNot(contains('posts')));
  });
}
