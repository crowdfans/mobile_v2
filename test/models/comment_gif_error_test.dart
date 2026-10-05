import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('erro do GIF não expõe API key nem config interna', () {
    final message = CommentGifService.userErrorMessage;
    expect(CommentGifService.messageExposesSecrets(message), isFalse);
    expect(message.toLowerCase(), contains('conexão'));
    expect(message.toLowerCase(), isNot(contains('api key')));
  });

  test('mensagem legada com API key é detectada', () {
    const legacy =
        'Não foi possível carregar os GIFs da Tenor. Verifique sua conexão ou API key.';
    expect(CommentGifService.messageExposesSecrets(legacy), isTrue);
  });
}
