import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-197 TEMP fixtures: featured + search + empty', () {
    expect(kUseCfTempMocks, isTrue);
    expect(kUseCf197GifMocks, isTrue);

    final featured = Cf197GifFixtures.featured();
    expect(featured, isNotEmpty);
    expect(featured.first.id, isNotEmpty);
    expect(featured.first.previewUrl, startsWith('http'));

    final searched = Cf197GifFixtures.itemsFor('rock');
    expect(searched, isNotEmpty);

    expect(Cf197GifFixtures.itemsFor('___sem_resultado___'), isEmpty);
    expect(Cf197GifFixtures.itemsFor('xyzzy'), isEmpty);
  });

  test('CF-197 mensagem de erro sem segredo', () {
    expect(
      CommentGifService.messageExposesSecrets(CommentGifService.userErrorMessage),
      isFalse,
    );
  });
}
