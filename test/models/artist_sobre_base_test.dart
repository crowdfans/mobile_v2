import 'package:flutter_test/flutter_test.dart';

String artistSobreBaseLabel(String? location) {
  final value = (location ?? '').trim();
  if (value.isEmpty) {
    return 'Não informado';
  }
  return value;
}

void main() {
  test('Base não inventa localização quando ausente', () {
    expect(artistSobreBaseLabel(null), 'Não informado');
    expect(artistSobreBaseLabel('  '), 'Não informado');
    expect(artistSobreBaseLabel('Rio de Janeiro, BR'), 'Rio de Janeiro, BR');
  });
}
