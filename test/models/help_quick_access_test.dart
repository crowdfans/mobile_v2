import 'package:crowdfans/content/help_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('acessos rápidos têm destinos descritivos (CF-198 HelpContent)', () {
    final labels = HelpContent.quickAccess().map((r) => r.title).toList();
    expect(labels, hasLength(4));
    expect(labels.every((l) => l.trim().isNotEmpty), isTrue);
    expect(labels.toSet(), hasLength(labels.length));
    expect(labels, [
      'Segurança e Login',
      'Meus Memberships',
      'Termos de Uso',
      'Política de Privacidade',
    ]);
  });
}
