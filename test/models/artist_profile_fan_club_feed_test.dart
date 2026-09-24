import 'package:crowdfans/components/profile/artist_profile_fan_club_feed.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter_test/flutter_test.dart';

FeedPost _post({
  required String id,
  required int votes,
  required int minutesAgo,
  PostType type = PostType.text,
  String? imageUri,
}) {
  return FeedPost(
    id: id,
    type: type,
    author: 'Fan',
    handle: 'fan',
    minutesAgo: minutesAgo,
    avatarUri: '',
    text: id,
    imageUri: imageUri,
    votes: votes,
    comments: 0,
    shares: 0,
  );
}

void main() {
  test('Novos ordena por recência; Populares por votos', () {
    final posts = [
      _post(id: 'a', votes: 10, minutesAgo: 30),
      _post(id: 'b', votes: 50, minutesAgo: 5),
      _post(id: 'c', votes: 20, minutesAgo: 10),
    ];
    final novos = artistProfileFanClubVisiblePosts(
      posts: posts,
      sortPopular: false,
      filter: ArtistProfileFanClubFilter.all,
    );
    expect(novos.map((p) => p.id), ['b', 'c', 'a']);

    final populares = artistProfileFanClubVisiblePosts(
      posts: posts,
      sortPopular: true,
      filter: ArtistProfileFanClubFilter.all,
    );
    expect(populares.map((p) => p.id), ['b', 'c', 'a']);
  });

  test('filtro Posts exclui mídia; Media mantém só mídia', () {
    final posts = [
      _post(id: 'text', votes: 1, minutesAgo: 1),
      _post(id: 'img', votes: 1, minutesAgo: 2, type: PostType.image),
      _post(id: 'uri', votes: 1, minutesAgo: 3, imageUri: 'https://x/y.jpg'),
    ];
    final onlyPosts = artistProfileFanClubVisiblePosts(
      posts: posts,
      sortPopular: false,
      filter: ArtistProfileFanClubFilter.posts,
    );
    expect(onlyPosts.map((p) => p.id), ['text']);

    final onlyMedia = artistProfileFanClubVisiblePosts(
      posts: posts,
      sortPopular: false,
      filter: ArtistProfileFanClubFilter.media,
    );
    expect(onlyMedia.map((p) => p.id), ['img', 'uri']);
  });
}
