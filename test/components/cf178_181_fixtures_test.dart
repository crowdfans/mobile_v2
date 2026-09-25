import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-178 mock feed: Felipe Rhy + Laís Costa do print', () {
    final posts = Cf178FanClubsFeedMock.posts();
    expect(posts, hasLength(2));
    expect(posts.first.author, 'Felipe Rhy');
    expect(posts.first.handle, 'fan/thiagok');
    expect(posts.first.votes, 1039);
    expect(posts.last.author, 'Laís Costa');
    expect(posts.last.type, 'carousel');
  });

  test('CF-181 mock cartas: autoria no topo da grade', () {
    final letters = Cf181CartasMock.letters(artistId: 'artist-1');
    expect(letters, hasLength(6));
    expect(letters.first.fanDisplayName, 'Aline Duarte');
    expect(letters.every((item) => item.artistId == 'artist-1'), isTrue);
  });
}
