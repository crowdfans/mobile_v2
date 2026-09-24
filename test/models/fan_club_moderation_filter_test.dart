import 'package:flutter_test/flutter_test.dart';

/// Filtro local do painel (mesma regra da tela).
bool matchesModerationQuery(String haystack, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return true;
  }
  return haystack.toLowerCase().contains(q);
}

void main() {
  test('busca vazia mantém todos os casos', () {
    expect(matchesModerationQuery('Anna Lu defesa', ''), isTrue);
    expect(matchesModerationQuery('Anna Lu defesa', '   '), isTrue);
  });

  test('busca filtra por nome, handle ou motivo', () {
    expect(matchesModerationQuery('Anna Lu fan/annalu defesa', 'annalu'), isTrue);
    expect(matchesModerationQuery('Vic Melo fan/vicmelo', 'expulsa'), isFalse);
    expect(
      matchesModerationQuery('Vic Melo quero voltar', 'voltar'),
      isTrue,
    );
  });
}
