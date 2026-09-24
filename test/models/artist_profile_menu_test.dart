import 'package:flutter_test/flutter_test.dart';

String artistProfileReportLabel(String artistName) {
  final name = artistName.trim().isEmpty ? 'artista' : artistName.trim();
  return 'Denunciar perfil de $name';
}

void main() {
  test('menu informa o objeto da denúncia', () {
    expect(artistProfileReportLabel('Gus Art'), 'Denunciar perfil de Gus Art');
    expect(artistProfileReportLabel(''), 'Denunciar perfil de artista');
  });
}
