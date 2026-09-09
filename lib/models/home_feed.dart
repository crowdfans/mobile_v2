import 'package:crowdfans/models/feed_post.dart';

class StoryItem {
  const StoryItem({
    required this.id,
    required this.name,
    required this.handle,
    required this.imageUri,
    this.featureType,
  });

  final String id;
  final String name;
  final String handle;
  final String imageUri;
  final String? featureType;

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    return StoryItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      imageUri: json['imageUri'] as String? ?? '',
      featureType: json['featureType'] as String?,
    );
  }
}

/// Artista seguido no payload de `GET /api/v1/home` (sidebar).
class HomeFollowedArtist {
  const HomeFollowedArtist({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  final String id;
  final String username;
  final String avatarUrl;

  factory HomeFollowedArtist.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return HomeFollowedArtist(
      id: map['id'] as String? ?? '',
      username: map['username'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, String> toJson() {
    return {'id': id, 'username': username, 'avatarUrl': avatarUrl};
  }
}

class HomeFeedDto {
  const HomeFeedDto({
    required this.feedPosts,
    required this.stories,
    this.followedArtists = const [],
    this.hasMore = false,
  });

  final List<FeedPost> feedPosts;
  final List<StoryItem> stories;
  final List<HomeFollowedArtist> followedArtists;
  final bool hasMore;

  factory HomeFeedDto.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return HomeFeedDto(
      feedPosts: [
        for (final item in map['feedPosts'] as List? ?? const [])
          FeedPost.fromJson(item as Map<String, dynamic>),
      ],
      stories: [
        for (final item in map['stories'] as List? ?? const [])
          StoryItem.fromJson(item as Map<String, dynamic>),
      ],
      followedArtists: [
        for (final item in map['followedArtists'] as List? ?? const [])
          HomeFollowedArtist.fromJson(item as Map<String, dynamic>),
      ],
      hasMore: map['hasMore'] == true,
    );
  }
}
