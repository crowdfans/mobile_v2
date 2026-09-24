import 'package:flutter_test/flutter_test.dart';

String sidebarStarLabel({required String name, required bool isFavorite}) {
  return isFavorite
      ? 'Remover $name dos favoritos'
      : 'Adicionar $name aos favoritos';
}

void main() {
  test('estrela da sidebar tem nome e estado', () {
    expect(
      sidebarStarLabel(name: 'Mayra', isFavorite: true),
      'Remover Mayra dos favoritos',
    );
    expect(
      sidebarStarLabel(name: 'Anitta', isFavorite: false),
      'Adicionar Anitta aos favoritos',
    );
  });
}
