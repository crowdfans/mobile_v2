import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-208 interações: intro + 5 rótulos do print', () {
    final group = notificationGroupById('interactions')!;
    expect(group.pageIntro, contains('interações pessoais'));
    expect(group.items.length, 5);
    expect(group.items.map((item) => item.title).toList(), [
      'Artista curtiu seu comentário',
      'Artista curtiu sua carta',
      'Respostas aos seus comentários',
      'Menções ao seu fan/',
      'Novos seguidores',
    ]);
  });

  test('CF-209 Meet & Greet: categorias e encerramento do print', () {
    final group = notificationGroupById('meet')!;
    expect(group.pageIntro, contains('encerramento das chamadas'));
    expect(group.items.length, 3);
    expect(group.items.map((item) => item.title).toList(), [
      'Convites para Meet & Greet',
      'Lembretes de Meet & Greet',
      'Resultado e encerramento',
    ]);
  });

  test('CF-211 Membership: ordem renovação → promo → saldo', () {
    final group = notificationGroupById('wallet')!;
    expect(group.pageIntro, contains('cobrança'));
    expect(group.items.length, 3);
    expect(group.items.map((item) => item.title).toList(), [
      'Renovação de membership',
      'Promoções de Jam Coins',
      'Saldo e pagamentos',
    ]);
    expect(group.items[0].critical, isTrue);
    expect(group.items[1].critical, isFalse);
    expect(group.items[2].critical, isTrue);
  });
}
