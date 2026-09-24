import 'package:flutter_test/flutter_test.dart';

/// Garante rótulos semânticos dos acessos rápidos da Ajuda.
List<String> helpQuickAccessLabels() => const [
  'Segurança e Login',
  'Meus Memberships',
  'Termos de Uso',
  'Política de Privacidade',
];

void main() {
  test('acessos rápidos têm destinos descritivos', () {
    final labels = helpQuickAccessLabels();
    expect(labels, hasLength(4));
    expect(labels.every((l) => l.trim().isNotEmpty), isTrue);
    expect(labels.toSet(), hasLength(labels.length));
  });
}
