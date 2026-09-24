import 'package:crowdfans/components/profile/artist_sobre_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Base não inventa localização quando ausente', () {
    expect(artistSobreBaseLabel(null), 'Não informado');
    expect(artistSobreBaseLabel('  '), 'Não informado');
    expect(artistSobreBaseLabel('Rio de Janeiro, BR'), 'Rio de Janeiro, BR');
  });
}
