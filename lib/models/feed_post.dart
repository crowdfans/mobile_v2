/// Tipos de post do feed.
enum PostType { text, image, carousel, video, membership, unknown }

PostType postTypeFrom(String? raw) {
  return switch (raw?.toLowerCase()) {
    'text' => PostType.text,
    'image' => PostType.image,
    'carousel' => PostType.carousel,
    'video' => PostType.video,
    'membership' => PostType.membership,
    _ => PostType.unknown,
  };
}

/// Post do `GET /api/v1/home`.
class FeedPost {
  const FeedPost({
    required this.id,
    required this.type,
    required this.author,
    required this.handle,
    required this.minutesAgo,
    required this.avatarUri,
    required this.text,
    required this.votes,
    required this.comments,
    required this.shares,
    this.artistId,
    this.imageUri,
    this.carouselUris = const [],
    this.videoThumbnailUri,
    this.isExclusive = false,
    this.exclusiveLocked = false,
    this.myVote = 0,
  });

  final String id;
  final PostType type;
  final String author;
  final String? artistId;
  final String handle;
  final int minutesAgo;
  final String avatarUri;
  final String text;
  final String? imageUri;
  final List<String> carouselUris;
  final String? videoThumbnailUri;
  final bool isExclusive;
  final bool exclusiveLocked;
  final int votes;
  final int myVote;
  final int comments;
  final int shares;

  FeedPost copyWith({int? votes, int? myVote, bool? exclusiveLocked}) {
    return FeedPost(
      id: id,
      type: type,
      author: author,
      artistId: artistId,
      handle: handle,
      minutesAgo: minutesAgo,
      avatarUri: avatarUri,
      text: text,
      imageUri: imageUri,
      carouselUris: carouselUris,
      videoThumbnailUri: videoThumbnailUri,
      isExclusive: isExclusive,
      exclusiveLocked: exclusiveLocked ?? this.exclusiveLocked,
      votes: votes ?? this.votes,
      myVote: myVote ?? this.myVote,
      comments: comments,
      shares: shares,
    );
  }

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] as String? ?? '',
      type: postTypeFrom(json['type'] as String?),
      author: json['author'] as String? ?? '',
      artistId: json['artistId'] as String?,
      handle: json['handle'] as String? ?? '',
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
      avatarUri: json['avatarUri'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUri: json['imageUri'] as String?,
      carouselUris: [
        for (final item in json['carouselUris'] as List? ?? const [])
          item.toString(),
      ],
      videoThumbnailUri: json['videoThumbnailUri'] as String?,
      isExclusive: json['isExclusive'] == true,
      exclusiveLocked: json['exclusiveLocked'] == true,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      myVote: (json['myVote'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
    );
  }
}
