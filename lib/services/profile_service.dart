import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/http_service.dart';

/// Post listado em `GET /profile/:userUID/posts`.
class UserProfilePost {
  const UserProfilePost({
    required this.postId,
    required this.userUid,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.type,
    this.isExclusive = false,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final String postId;
  final String userUid;
  final String title;
  final String content;
  final String? imageUrl;
  final String? type;
  final bool isExclusive;
  final String createdAt;
  final int likesCount;
  final int commentsCount;

  factory UserProfilePost.fromJson(Map<String, dynamic> json) {
    return UserProfilePost(
      postId: json['postId'] as String? ?? '',
      userUid: json['userUid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String?,
      isExclusive: json['isExclusive'] == true,
      createdAt: json['createdAt'] as String? ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
    );
  }

  FeedPost toFeedPost({required Profile owner}) {
    final created = DateTime.tryParse(createdAt);
    final minutes = created == null
        ? 0
        : DateTime.now().difference(created).inMinutes.clamp(0, 999999);
    return FeedPost(
      id: postId,
      type: postTypeFrom(type),
      author: owner.displayName,
      artistId: owner.isArtist ? owner.userUid : null,
      handle: owner.name,
      minutesAgo: minutes,
      avatarUri: owner.photoUrl,
      text: content.isEmpty ? title : content,
      imageUri: imageUrl,
      votes: likesCount,
      comments: commentsCount,
      shares: 0,
      isExclusive: isExclusive,
      exclusiveLocked: isExclusive,
    );
  }
}

/// Perfil do usuário autenticado e posts por UID.
abstract final class ProfileService {
  static Future<Profile> getMyProfile() {
    return HttpService.request<Profile>(
      ApiUrls.profile,
      parse: (json) => Profile.fromJson(json! as Map<String, dynamic>),
    );
  }

  static Future<void> updateMyProfile({
    String? displayName,
    String? name,
    String? description,
    String? photoUrl,
  }) async {
    await HttpService.request<dynamic>(
      ApiUrls.profile,
      method: Method.put,
      body: {
        'displayName': ?displayName,
        'name': ?name,
        'description': ?description,
        'photoUrl': ?photoUrl,
      },
    );
  }

  static Future<List<UserProfilePost>> getPostsByUserUid(
    String userUid, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = Uri(
      queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
    );
    final data = await HttpService.request<Map<String, dynamic>>(
      '${ApiUrls.withParams(ApiUrls.profileUserPosts, {'userUID': userUid})}?${params.query}',
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['posts'] as List? ?? const [])
        UserProfilePost.fromJson(item as Map<String, dynamic>),
    ];
  }
}
