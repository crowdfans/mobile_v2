import 'package:crowdfans/models/feed_post.dart';

/// Filtra publicações do Meu Perfil pelo fã-clube (artistId) selecionado.
List<FeedPost> mePostsForFanClub({
  required List<FeedPost> posts,
  required String? artistId,
}) {
  final id = (artistId ?? '').trim();
  if (id.isEmpty) {
    return posts;
  }
  return [
    for (final post in posts)
      if ((post.artistId ?? '').trim() == id) post,
  ];
}
