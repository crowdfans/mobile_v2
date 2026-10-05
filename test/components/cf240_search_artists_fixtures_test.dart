import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-240 — Buscar artistas: demock (API real) + helpers de print.
void main() {
  group('CF-240 green', () {
    test('useSearchArtistsFixtures off (demock)', () {
      expect(kUseCfTempMocks, isTrue);
      expect(CfTempMocks.useSearchArtistsFixtures, isFalse);
    });

    test('helper print L → Ludmilla…Carol Biazin com membros e #rank', () {
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
  });

  group('CF-240 red', () {
    test('query vazia não força fixture', () {
      expect(cfTempMockSearchArtists(''), isNull);
      expect(cfTempMockSearchArtists('   '), isNull);
    });

    test('query sem match devolve null (UI usa API / vazio)', () {
      expect(cfTempMockSearchArtists('zzzz-no-match'), isNull);
    });
  });

  group('CF-240 edge', () {
    test('case-insensitive L e filtro parcial', () {
      expect(cfTempMockSearchArtists('l')!.length, 5);
      expect(cfTempMockSearchArtists('L')!.length, 5);
      final anitta = cfTempMockSearchArtists('ani');
      expect(anitta, isNotNull);
      expect(anitta!.single.name, 'Anitta');
    });

    test('fixtures off: helper ainda disponível para asserts de print', () {
      expect(CfTempMocks.useSearchArtistsFixtures, isFalse);
      expect(cfTempMockSearchArtists('L'), isNotNull);
    });
  });
}
