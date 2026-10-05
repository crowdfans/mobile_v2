import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-197 GIF demock — green', () {
    test('flag off; fixtures de print ainda disponíveis para testes', () {
      expect(kUseCfTempMocks, isTrue);
      expect(kUseCf197GifMocks, isFalse);

      final featured = Cf197GifFixtures.featured();
      expect(featured, isNotEmpty);
      expect(featured.first.id, isNotEmpty);
      expect(featured.first.previewUrl, startsWith('http'));

      final searched = Cf197GifFixtures.itemsFor('rock');
      expect(searched, isNotEmpty);
    });

    test('com TENOR_API_KEY presente, hasApiKey é true', () {
      dotenv.loadFromString(envString: 'TENOR_API_KEY=test-tenor-key-cf197\n');
      expect(CommentGifService.hasApiKey, isTrue);
      expect(CommentGifService.apiKey, 'test-tenor-key-cf197');
    });
  });

  group('CF-197 GIF demock — red', () {
    test('sem chave → ApiError com mensagem segura (não blank)', () async {
      dotenv.loadFromString(envString: '', isOptional: true);
      expect(CommentGifService.hasApiKey, isFalse);

      try {
        await CommentGifService.fetchCommentGifs();
        fail('esperava ApiError sem TENOR_API_KEY');
      } on ApiError catch (error) {
        expect(error.message, CommentGifService.userErrorMessage);
        expect(
          CommentGifService.messageExposesSecrets(error.message),
          isFalse,
        );
        expect(error.message.toLowerCase(), isNot(contains('api key')));
      }
    });

    test('mensagem de erro sem segredo', () {
      expect(
        CommentGifService.messageExposesSecrets(
          CommentGifService.userErrorMessage,
        ),
        isFalse,
      );
    });
  });

  group('CF-197 GIF demock — edge', () {
    test('fixtures empty vs featured; EXPO_PUBLIC alias', () {
      expect(Cf197GifFixtures.itemsFor('___sem_resultado___'), isEmpty);
      expect(Cf197GifFixtures.itemsFor('xyzzy'), isEmpty);
      expect(Cf197GifFixtures.itemsFor(''), isNotEmpty);

      dotenv.loadFromString(
        envString: 'EXPO_PUBLIC_TENOR_API_KEY=expo-alias-key\n',
      );
      expect(CommentGifService.hasApiKey, isTrue);
      expect(CommentGifService.apiKey, 'expo-alias-key');
    });

    test('chave só com espaços conta como ausente', () {
      dotenv.loadFromString(envString: 'TENOR_API_KEY=   \n');
      expect(CommentGifService.hasApiKey, isFalse);
    });
  });
}
