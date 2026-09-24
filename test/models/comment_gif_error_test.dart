import 'package:flutter_test/flutter_test.dart';

/// Mensagem de erro do seletor de GIF (nunca citar API key).
String commentGifUserErrorMessage() =>
    'Não foi possível carregar os GIFs. Verifique sua conexão e tente novamente.';

bool messageExposesSecrets(String message) {
  final lower = message.toLowerCase();
  return lower.contains('api key') ||
      lower.contains('apikey') ||
      lower.contains('tenor.googleapis') ||
      lower.contains('livdsrzulela');
}

void main() {
  test('erro do GIF não expõe API key nem config interna', () {
    final message = commentGifUserErrorMessage();
    expect(messageExposesSecrets(message), isFalse);
    expect(message.toLowerCase(), contains('conexão'));
  });
}
