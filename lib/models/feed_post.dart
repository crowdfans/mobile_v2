/// Tipos de post do feed.
enum PostType { text, image, carousel, video, membership, unknown }

/// Tipos escolhíveis na criação de post (sem `unknown`).
const createPostTypes = [
  PostType.text,
  PostType.image,
  PostType.carousel,
  PostType.video,
  PostType.membership,
];

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

/// Valor enviado ao backend (`text`, `image`, ...).
String postTypeToApi(PostType type) {
  return switch (type) {
    PostType.text => 'text',
    PostType.image => 'image',
    PostType.carousel => 'carousel',
    PostType.video => 'video',
    PostType.membership => 'membership',
    PostType.unknown => 'text',
  };
}

/// Rótulo de UI do tipo de post.
String postTypeLabel(PostType type) {
  return switch (type) {
    PostType.text => 'Texto',
    PostType.image => 'Imagem',
    PostType.carousel => 'Carrossel',
    PostType.video => 'Vídeo',
    PostType.membership => 'Membership',
    PostType.unknown => 'Post',
  };
}

/// Selo de membership do autor no header do post.
class MembershipBadgeInfo {
  const MembershipBadgeInfo({required this.label, this.tier});

  final String label;
  final String? tier;

  factory MembershipBadgeInfo.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return MembershipBadgeInfo(
      label: map['label'] as String? ?? '',
      tier: map['tier'] as String?,
    );
  }
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
    this.rank,
    this.videoUri,
    this.videoDuration,
    this.membershipTitle,
    this.exclusiveLocked = false,
    this.membershipLocked = false,
    this.myVote = 0,
    this.clubArtistName,
    this.clubArtistAvatarUri,
    this.posterAvatarUri,
    this.isSecret = false,
    this.membershipBadges = const [],
  });

  final String id;
  final PostType type;
  final String author;
  final String? artistId;
  final String handle;
  final String? rank;
  final int minutesAgo;
  final String avatarUri;
  final String text;
  final String? imageUri;
  final List<String> carouselUris;
  final String? videoThumbnailUri;
  final String? videoUri;
  final String? videoDuration;
  final String? membershipTitle;
  final bool isExclusive;
  final bool exclusiveLocked;
  final bool membershipLocked;
  final int votes;
  final int myVote;
  final int comments;
  final int shares;
  final String? clubArtistName;
  final String? clubArtistAvatarUri;
  final String? posterAvatarUri;
  final bool isSecret;
  final List<MembershipBadgeInfo> membershipBadges;

  FeedPost copyWith({int? votes, int? myVote, bool? exclusiveLocked}) {
    return FeedPost(
      id: id,
      type: type,
      author: author,
      artistId: artistId,
      handle: handle,
      rank: rank,
      minutesAgo: minutesAgo,
      avatarUri: avatarUri,
      text: text,
      imageUri: imageUri,
      carouselUris: carouselUris,
      videoThumbnailUri: videoThumbnailUri,
      videoUri: videoUri,
      videoDuration: videoDuration,
      membershipTitle: membershipTitle,
      isExclusive: isExclusive,
      exclusiveLocked: exclusiveLocked ?? this.exclusiveLocked,
      membershipLocked: membershipLocked,
      votes: votes ?? this.votes,
      myVote: myVote ?? this.myVote,
      comments: comments,
      shares: shares,
      clubArtistName: clubArtistName,
      clubArtistAvatarUri: clubArtistAvatarUri,
      posterAvatarUri: posterAvatarUri,
      isSecret: isSecret,
      membershipBadges: membershipBadges,
    );
  }

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] as String? ?? '',
      type: postTypeFrom(json['type'] as String?),
      author: json['author'] as String? ?? '',
      artistId: json['artistId'] as String?,
      handle: json['handle'] as String? ?? '',
      rank: json['rank'] as String?,
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
      avatarUri: json['avatarUri'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUri: json['imageUri'] as String?,
      carouselUris: [
        for (final item in json['carouselUris'] as List? ?? const [])
          item.toString(),
      ],
      videoThumbnailUri: json['videoThumbnailUri'] as String?,
      videoUri: json['videoUri'] as String?,
      videoDuration: json['videoDuration'] as String?,
      membershipTitle: json['membershipTitle'] as String?,
      isExclusive: json['isExclusive'] == true,
      exclusiveLocked: json['exclusiveLocked'] == true,
      membershipLocked: json['membershipLocked'] == true,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      myVote: (json['myVote'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      clubArtistName: json['clubArtistName'] as String?,
      clubArtistAvatarUri: json['clubArtistAvatarUri'] as String?,
      posterAvatarUri: json['posterAvatarUri'] as String?,
      isSecret: json['isSecret'] == true || json['isSecretMode'] == true,
      membershipBadges: [
        for (final item in json['membershipBadges'] as List? ?? const [])
          MembershipBadgeInfo.fromJson(item),
      ],
    );
  }
}

/// Home Superfã: só post de artista. Se a API não mandar `artistId`, não esvazia o feed.
bool isArtistFeedPost(FeedPost post) {
  if ((post.artistId ?? '').trim().isNotEmpty) {
    return true;
  }
  final handle = post.handle.toLowerCase().replaceFirst(RegExp(r'^@'), '');
  return handle.startsWith('artist/');
}

List<FeedPost> artistHomePosts(List<FeedPost> posts) {
  final filtered = [
    for (final post in posts)
      if (isArtistFeedPost(post)) post,
  ];
  return filtered.isEmpty ? posts : filtered;
}
