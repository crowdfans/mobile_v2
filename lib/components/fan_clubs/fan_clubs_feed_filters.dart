import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/community_service.dart';

/// Filtro de conteúdo do feed “Postagens dos Fã Clubes” (CF-178).
enum FanClubsContentFilter { all, posts, media }

/// Post com mídia (imagem / carrossel / vídeo / imageUri).
bool isFanClubsMediaPost(CommunityPost post) {
  final type = post.type.toLowerCase();
  return type == 'image' ||
      type == 'carousel' ||
      type == 'video' ||
      (post.imageUri?.trim().isNotEmpty ?? false);
}

/// Ordena e aplica Todos / Posts / Media no feed de fã-clubes.
List<CommunityPost> fanClubsVisiblePosts({
  required List<CommunityPost> posts,
  required bool sortPopular,
  required FanClubsContentFilter filter,
}) {
  final sorted = [...posts];
  if (sortPopular) {
    sorted.sort((a, b) => b.votes.compareTo(a.votes));
  } else {
    sorted.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
  }
  return switch (filter) {
    FanClubsContentFilter.all => sorted,
    FanClubsContentFilter.posts => [
      for (final post in sorted)
        if (!isFanClubsMediaPost(post)) post,
    ],
    FanClubsContentFilter.media => [
      for (final post in sorted)
        if (isFanClubsMediaPost(post)) post,
    ],
  };
}

/// Cópia do vazio no feed (filtros permanecem no chrome fora da lista).
String fanClubsEmptyMessage({required bool hasArtists}) {
  return hasArtists
      ? 'Nenhum post na comunidade ainda.'
      : 'Siga artistas para ver posts da comunidade aqui.';
}

/// Gate do fixture CF-178: só entra com API vazia **e** flag ligada.
bool shouldUseCf178FanClubsFeedFixtures(List<CommunityPost> apiPosts) {
  return apiPosts.isEmpty && kUseCfTempMocks && kUseCf178FanClubsFeedMocks;
}
