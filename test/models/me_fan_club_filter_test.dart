import 'package:crowdfans/components/profile/me_fan_club_filter.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter_test/flutter_test.dart';

FeedPost _post(String id, {String? artistId}) {
  return FeedPost(
    id: id,
    type: PostType.text,
    author: 'A',
    handle: 'a',
    minutesAgo: 1,
    avatarUri: '',
    text: id,
    votes: 0,
    comments: 0,
    shares: 0,
    artistId: artistId,
  );
}

void main() {
  test('sem artista selecionado mantém todas as publicações', () {
    final posts = [_post('1', artistId: 'a'), _post('2', artistId: 'b')];
    expect(mePostsForFanClub(posts: posts, artistId: null).length, 2);
    expect(mePostsForFanClub(posts: posts, artistId: '  ').length, 2);
  });

  test('com artista selecionado filtra por artistId', () {
    final posts = [
      _post('1', artistId: 'a'),
      _post('2', artistId: 'b'),
      _post('3', artistId: 'a'),
    ];
    final filtered = mePostsForFanClub(posts: posts, artistId: 'a');
    expect(filtered.map((p) => p.id), ['1', '3']);
  });
}
