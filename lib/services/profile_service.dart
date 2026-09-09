import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/membership.dart';
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
  /// Normaliza handle de fã para comparação / navegação (`fan/username`).
  static String normalizeFanHandle(String value) {
    var handle = value.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    if (handle.isEmpty) {
      return '';
    }
    if (handle.startsWith('fan/')) {
      return handle;
    }
    return 'fan/${handle.replaceAll(RegExp(r'\s+'), '')}';
  }

  static Future<Profile> getMyProfile() {
    return HttpService.request<Profile>(
      ApiUrls.profile,
      parse: (json) => Profile.fromJson(json! as Map<String, dynamic>),
    );
  }

  static Future<Profile> getProfileByUserUid(String userUid) {
    return HttpService.request<Profile>(
      ApiUrls.withParams(ApiUrls.profileByUid, {'userUID': userUid}),
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

  /// Memberships ativas e catálogo (`GET /api/v1/profiles/:handle/memberships`).
  static Future<MembershipOverview> getMemberships(String profileHandle) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.profileMemberships, {'handle': profileHandle}),
      parse: MembershipOverview.fromJson,
    );
  }

  /// Visão pública (`GET /api/v1/profiles/:handle/overview`).
  static Future<ProfileOverview> getProfileOverview(String handle) {
    final normalized = normalizeFanHandle(handle);
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.profileView, {
        'handle': normalized.isEmpty ? handle : normalized,
      }),
      parse: ProfileOverview.fromJson,
    );
  }

  /// Artistas seguidos (`GET /api/v1/profiles/:handle/social`).
  static Future<FollowedArtistsResponse> getFollowedArtists(String handle) {
    final normalized = normalizeFanHandle(handle);
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.profileSocial, {
        'handle': normalized.isEmpty ? handle : normalized,
      }),
      parse: FollowedArtistsResponse.fromJson,
    );
  }

  /// Fan Score (`GET /api/v1/profiles/:handle/fan-score`).
  static Future<FanScoreData> getFanScore(String handle) {
    final normalized = normalizeFanHandle(handle);
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.profileFanScore, {
        'handle': normalized.isEmpty ? handle : normalized,
      }),
      parse: FanScoreData.fromJson,
    );
  }
}
