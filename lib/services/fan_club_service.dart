import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Metadados do fan club (`GET /artist/:artistUid/fanclub`).
class ArtistFanClub {
  const ArtistFanClub({
    required this.id,
    required this.name,
    required this.description,
    required this.artistUid,
    required this.artistName,
    required this.isActive,
    required this.memberCount,
    required this.isMember,
    this.viewerIsModerator = false,
    this.viewerIsOwner = false,
  });

  final int id;
  final String name;
  final String description;
  final String artistUid;
  final String artistName;
  final bool isActive;
  final int memberCount;
  final bool isMember;
  final bool viewerIsModerator;
  final bool viewerIsOwner;

  factory ArtistFanClub.fromJson(Map<String, dynamic> json) {
    return ArtistFanClub(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      artistUid: json['artistUid'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      isActive: json['isActive'] == true,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      isMember: json['isMember'] == true,
      viewerIsModerator: json['viewerIsModerator'] == true,
      viewerIsOwner: json['viewerIsOwner'] == true,
    );
  }
}

class FanClubFeedPost {
  const FanClubFeedPost({
    required this.postId,
    required this.content,
    required this.createdAt,
    this.title,
    this.imageUrl,
    this.type,
    this.isExclusive = false,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final String postId;
  final String? title;
  final String content;
  final String? imageUrl;
  final String? type;
  final bool isExclusive;
  final String createdAt;
  final int likesCount;
  final int commentsCount;

  factory FanClubFeedPost.fromJson(Map<String, dynamic> json) {
    return FanClubFeedPost(
      postId: json['postId'] as String? ?? '',
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String?,
      isExclusive: json['isExclusive'] == true,
      createdAt: json['createdAt'] as String? ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ArtistFanClubFeed {
  const ArtistFanClubFeed({required this.fanClub, this.posts = const []});

  final ArtistFanClub fanClub;
  final List<FanClubFeedPost> posts;

  factory ArtistFanClubFeed.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    final clubJson = map['fanClub'] as Map<String, dynamic>? ?? {};
    return ArtistFanClubFeed(
      fanClub: ArtistFanClub.fromJson(clubJson),
      posts: [
        for (final item in map['posts'] as List? ?? const [])
          FanClubFeedPost.fromJson(item as Map<String, dynamic>),
      ],
    );
  }
}

/// Fan club do artista (`/api/v1/artist/:artistUid/fanclub`).
abstract final class FanClubService {
  static Future<ArtistFanClubFeed?> getArtistFanClubFeed(
    String artistUid, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = Uri(
      queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
    );
    try {
      return await HttpService.request(
        '${ApiUrls.withParams(ApiUrls.artistFanclub, {'artistUid': artistUid})}?${params.query}',
        parse: ArtistFanClubFeed.fromJson,
      );
    } on ApiError catch (error) {
      if (error.status == 404) {
        return null;
      }
      rethrow;
    }
  }
}
