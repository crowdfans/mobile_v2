import 'package:flutter_test/flutter_test.dart';

String notificationEmptyForTab(String tab) {
  return switch (tab) {
    'all' => 'Nenhuma notificação por aqui ainda.',
    'posts' => 'Nenhuma notificação de posts nesta aba.',
    'clubs' => 'Nenhuma notificação de fã-clubes nesta aba.',
    'meet' => 'Nenhum lembrete de Meet & Greet nesta aba.',
    'fanletter' => 'Nenhuma notificação de cartas nesta aba.',
    _ => 'Nenhuma notificação do sistema nesta aba.',
  };
}

void main() {
  test('cada categoria tem vazio próprio', () {
    expect(notificationEmptyForTab('posts'), contains('posts'));
    expect(notificationEmptyForTab('meet'), contains('Meet'));
    expect(
      notificationEmptyForTab('posts'),
      isNot(equals(notificationEmptyForTab('clubs'))),
    );
  });
}
