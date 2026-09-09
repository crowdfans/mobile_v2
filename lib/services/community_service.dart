import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/http_service.dart';

/// Post do feed de comunidade / fan clubs.
class CommunityPost {
  const CommunityPost({
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
    this.imageUri,
    this.myVote = 0,
    this.targetArtistId,
    this.isExclusive = false,
    this.exclusiveLocked = false,
    this.isSecret = false,
    this.fanAvatarUri = '',
    this.membershipBadges = const [],
  });

  final String id;
  final String type;
  final String author;
  final String handle;
  final int minutesAgo;
  final String avatarUri;
  final String text;
  final String? imageUri;
  final int votes;
  final int myVote;
  final int comments;
  final int shares;
  final String? targetArtistId;
  final bool isExclusive;
  final bool exclusiveLocked;
  final bool isSecret;
  final String fanAvatarUri;
  final List<MembershipBadgeInfo> membershipBadges;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      author: json['author'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
      avatarUri: json['avatarUri'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUri: json['imageUri'] as String?,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      myVote: (json['myVote'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      targetArtistId: json['targetArtistId'] as String?,
      isExclusive: json['isExclusive'] == true,
      exclusiveLocked: json['exclusiveLocked'] == true,
      isSecret: json['isSecret'] == true,
      fanAvatarUri: json['fanAvatarUri'] as String? ?? '',
      membershipBadges: [
        for (final item in json['membershipBadges'] as List? ?? const [])
          MembershipBadgeInfo.fromJson(item),
      ],
    );
  }

  FeedPost toFeedPost() {
    final fan = fanAvatarUri.trim();
    return FeedPost(
      id: id,
      type: postTypeFrom(type),
      author: author,
      artistId: targetArtistId,
      handle: handle,
      minutesAgo: minutesAgo,
      avatarUri: avatarUri,
      text: text,
      imageUri: imageUri,
      votes: votes,
      myVote: myVote,
      comments: comments,
      shares: shares,
      isExclusive: isExclusive,
      exclusiveLocked: exclusiveLocked,
      isSecret: isSecret,
      membershipBadges: membershipBadges,
      clubArtistName: fan.isEmpty ? null : author,
      clubArtistAvatarUri: fan.isEmpty ? null : avatarUri,
      posterAvatarUri: fan.isEmpty ? null : fan,
    );
  }
}

/// Posts da comunidade (`GET /api/v1/community/posts`).
abstract final class CommunityService {
  static Future<List<CommunityPost>> getCommunityPosts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = Uri(
      queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
    );
    final data = await HttpService.request<Map<String, dynamic>>(
      '${ApiUrls.communityPosts}?${params.query}',
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['posts'] as List? ?? const [])
        CommunityPost.fromJson(item as Map<String, dynamic>),
    ];
  }
}
