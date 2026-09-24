import 'package:crowdfans/models/feed_post.dart';

/// Filtro Todos / Posts / Media do feed embutido na aba Fã Clube.
enum ArtistProfileFanClubFilter { all, posts, media }

bool artistProfileFanClubIsMedia(FeedPost post) {
  return post.type == PostType.image ||
      post.type == PostType.carousel ||
      post.type == PostType.video ||
      (post.imageUri?.trim().isNotEmpty ?? false);
}

/// Ordena e filtra posts da comunidade para a aba Fã Clube do perfil.
List<FeedPost> artistProfileFanClubVisiblePosts({
  required List<FeedPost> posts,
  required bool sortPopular,
  required ArtistProfileFanClubFilter filter,
}) {
  final list = [...posts];
  if (sortPopular) {
    list.sort((a, b) {
      final byVotes = b.votes.compareTo(a.votes);
      if (byVotes != 0) {
        return byVotes;
      }
      return a.minutesAgo.compareTo(b.minutesAgo);
    });
  } else {
    list.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
  }
  return switch (filter) {
    ArtistProfileFanClubFilter.all => list,
    ArtistProfileFanClubFilter.posts => [
      for (final post in list)
        if (!artistProfileFanClubIsMedia(post)) post,
    ],
    ArtistProfileFanClubFilter.media => [
      for (final post in list)
        if (artistProfileFanClubIsMedia(post)) post,
    ],
  };
}
