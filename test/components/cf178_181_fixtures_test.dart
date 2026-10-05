import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-178 mock feed documenta print (flag off em prod)', () {
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    final posts = Cf178FanClubsFeedMock.posts();
    expect(posts, hasLength(2));
    expect(posts.first.author, 'Felipe Rhy');
    expect(posts.first.handle, 'fan/thiagok');
    expect(posts.first.votes, 1039);
    expect(posts.last.author, 'Laís Costa');
    expect(posts.last.type, 'carousel');
  });

  test('CF-181 mock cartas: print image4/image5 (nomes + stickers)', () {
    expect(kUseCf181CartasMocks, isTrue);
    final letters = Cf181CartasMock.letters(artistId: 'artist-1');
    expect(letters, hasLength(9));
    expect(
      letters.map((item) => item.fanDisplayName).toList(),
      [
        'Aline Duarte',
        'Aline Duarte',
        'Maria Eduarda',
        'Caio Loux',
        'João Ribeiro',
        'Anna Lu',
        'Lia Costa',
        'Rafa Nogueira',
        'Vic Melo',
      ],
    );
    expect(letters.map((item) => item.bodyText).take(6).toList(), [
      'xhxucucucic',
      'LUDMILLA',
      'TEU SOM ME SALVA',
      'SHOW LOTADO',
      'VOCE ACENOU',
      'MEU CONFORTO',
    ]);
    expect(letters.every((item) => item.artistId == 'artist-1'), isTrue);
    expect(letters.every((item) => item.fanAvatarUri.isNotEmpty), isTrue);
    expect(Cf181CartasMock.stickersFor('cf181-1'), isNotEmpty);
    expect(Cf181CartasMock.stickersFor('cf181-5').first.asset, contains('cactus'));
    expect(Cf181CartasMock.stickersFor('unknown'), isEmpty);
  });
}
