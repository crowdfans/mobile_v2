import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-208 interações tem 5 switches aprovados', () {
    final group = notificationGroupById('interactions')!;
    expect(group.items.length, 5);
    expect(group.items.map((item) => item.title).toList(), [
      'Curtida do artista no comentário',
      'Curtida do artista na carta',
      'Respostas',
      'Menções',
      'Novos seguidores',
    ]);
  });

  test('CF-209 Meet & Greet com convites, lembretes e resultado', () {
    final group = notificationGroupById('meet')!;
    expect(group.items.length, 3);
    expect(group.items.last.title, 'Resultado e encerramento');
  });

  test('CF-211 Membership separa transacional de marketing', () {
    final group = notificationGroupById('wallet')!;
    expect(group.items.length, 3);
    expect(group.items[0].critical, isTrue);
    expect(group.items[1].critical, isTrue);
    expect(group.items[2].critical, isFalse);
    expect(group.items[2].title, contains('Promoções'));
  });
}
