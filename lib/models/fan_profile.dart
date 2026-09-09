import 'package:crowdfans/models/feed_post.dart';

/// Metadados públicos de um fã (`GET /api/v1/profiles/:handle/overview`).
class FanProfileMeta {
  const FanProfileMeta({
    required this.handle,
    required this.displayName,
    required this.avatarUri,
    required this.bio,
    required this.postsCount,
    required this.cardsCount,
    this.userUid,
  });

  final String? userUid;
  final String handle;
  final String displayName;
  final String avatarUri;
  final String bio;
  final String postsCount;
  final String cardsCount;

  factory FanProfileMeta.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanProfileMeta(
      userUid: map['userUid'] as String?,
      handle: map['handle']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      avatarUri:
          map['avatarUri']?.toString() ?? map['photoUrl']?.toString() ?? '',
      bio: map['bio']?.toString() ?? map['description']?.toString() ?? '',
      postsCount: map['postsCount']?.toString() ?? '0',
      cardsCount: map['cardsCount']?.toString() ?? '0',
    );
  }
}

/// Artista seguido exibido no perfil público.
class FollowedArtist {
  const FollowedArtist({
    required this.id,
    required this.label,
    required this.memberCount,
    this.avatarUri,
  });

  final String id;
  final String label;
  final String? avatarUri;
  final String memberCount;

  factory FollowedArtist.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FollowedArtist(
      id: map['id']?.toString() ?? map['artistUid']?.toString() ?? '',
      label: map['label']?.toString() ?? map['artistName']?.toString() ?? '',
      avatarUri:
          map['avatarUri'] as String? ??
          map['avatarUrl'] as String? ??
          map['photoUrl'] as String?,
      memberCount: map['memberCount']?.toString() ?? '0',
    );
  }
}

/// Visão pública: identidade, posts e artistas seguidos.
class ProfileOverview {
  const ProfileOverview({
    required this.profile,
    this.posts = const [],
    this.followedArtists = const [],
  });

  final FanProfileMeta profile;
  final List<FeedPost> posts;
  final List<FollowedArtist> followedArtists;

  factory ProfileOverview.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ProfileOverview(
      profile: FanProfileMeta.fromJson(map['profile']),
      posts: [
        for (final item in map['posts'] as List? ?? const [])
          FeedPost.fromJson(item as Map<String, dynamic>),
      ],
      followedArtists: [
        for (final item in map['followedArtists'] as List? ?? const [])
          FollowedArtist.fromJson(item),
      ],
    );
  }
}

/// Resposta de `GET /api/v1/profiles/:handle/social`.
class FollowedArtistsResponse {
  const FollowedArtistsResponse({
    required this.profile,
    this.followedArtists = const [],
  });

  final FanProfileMeta profile;
  final List<FollowedArtist> followedArtists;

  factory FollowedArtistsResponse.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FollowedArtistsResponse(
      profile: FanProfileMeta.fromJson(map['profile']),
      followedArtists: [
        for (final item in map['followedArtists'] as List? ?? const [])
          FollowedArtist.fromJson(item),
      ],
    );
  }
}
