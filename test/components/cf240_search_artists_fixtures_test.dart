import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-240 — Buscar artistas “L”: fixtures TEMP + flag ligado.
void main() {
  test('CF-240: useSearchArtistsFixtures TEMP on', () {
    expect(kUseCfTempMocks, isTrue);
    expect(CfTempMocks.useSearchArtistsFixtures, isTrue);
  });

  test('CF-240: busca L → Ludmilla…Carol Biazin com membros e #rank', () {
    final search = cfTempMockSearchArtists('L');
    expect(search, isNotNull);
    expect(search!.map((a) => a.name).toList(), [
      'Ludmilla',
      'Anitta',
      'Mayra',
      'Banda Uelo',
      'Carol Biazin',
    ]);
    expect(search.map((a) => a.membersLabel).toList(), [
      '512 mil membros',
      '487 mil membros',
      '368 mil membros',
      '228 mil membros',
      '196 mil membros',
    ]);
    expect(search.map((a) => a.rank).toList(), [1, 2, 3, 4, 5]);
    expect(search.first.handle.replaceFirst('@', ''), 'ludmilla');
    expect(search.last.handle.replaceFirst('@', ''), 'carolbiazin');
  });

  test('CF-240: query vazia não força fixture', () {
    expect(cfTempMockSearchArtists(''), isNull);
    expect(cfTempMockSearchArtists('   '), isNull);
  });
}
