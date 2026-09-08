import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/http_service.dart';

/// Post CRUD (`GET/POST /api/v1/post`, lista em `/api/v1/profile/posts`).
class UserPost {
  const UserPost({
    required this.id,
    required this.userId,
    required this.type,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.imageUri,
    this.imageUris = const [],
    this.videoUri,
    this.videoDurationMs,
    this.membershipTitle,
  });

  final String id;
  final String userId;
  final PostType type;
  final String text;
  final String? imageUri;
  final List<String> imageUris;
  final String? videoUri;
  final int? videoDurationMs;
  final String? membershipTitle;
  final String createdAt;
  final String updatedAt;

  factory UserPost.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return UserPost(
      id: map['postId'] as String? ?? map['id'] as String? ?? '',
      userId: map['userUid'] as String? ?? map['userId'] as String? ?? '',
      type: postTypeFrom(map['type'] as String?),
      text:
          ((map['content'] as String? ??
                      map['title'] as String? ??
                      map['text'] as String?) ??
                  '')
              .trim(),
      imageUri: map['imageUrl'] as String? ?? map['imageUri'] as String?,
      imageUris: [
        for (final item in map['imageUris'] as List? ?? const [])
          item.toString(),
      ],
      videoUri: map['videoUri'] as String?,
      videoDurationMs: (map['videoDurationMs'] as num?)?.toInt(),
      membershipTitle: map['membershipTitle'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt:
          map['updatedAt'] as String? ?? map['createdAt'] as String? ?? '',
    );
  }
}

/// Payload de criação / atualização de post.
class PostWriteRequest {
  const PostWriteRequest({
    required this.type,
    required this.text,
    this.imageUri,
    this.imageUris,
    this.videoUri,
    this.videoDurationMs,
    this.membershipTitle,
    this.targetArtistId,
  });

  final PostType type;
  final String text;
  final String? imageUri;
  final List<String>? imageUris;
  final String? videoUri;
  final int? videoDurationMs;
  final String? membershipTitle;
  final String? targetArtistId;

  Map<String, Object?> toJson() {
    return {
      'type': postTypeToApi(type),
      'text': text,
      if (imageUri != null) 'imageUri': imageUri,
      if (imageUris != null) 'imageUris': imageUris,
      if (videoUri != null) 'videoUri': videoUri,
      if (videoDurationMs != null) 'videoDurationMs': videoDurationMs,
      if (membershipTitle != null) 'membershipTitle': membershipTitle,
      if (targetArtistId != null) 'targetArtistId': targetArtistId,
    };
  }
}

/// CRUD de posts — espelho do `PostService` do Expo.
abstract final class PostService {
  /// Cria um post (`POST /api/v1/post`).
  static Future<UserPost> createPost(PostWriteRequest request) {
    return HttpService.request<UserPost>(
      ApiUrls.postCreate,
      method: Method.post,
      body: request.toJson(),
      parse: UserPost.fromJson,
    );
  }

  /// Atualiza um post (`PUT /api/v1/post/update/:id`).
  static Future<UserPost> updatePost(String postId, PostWriteRequest request) {
    return HttpService.request<UserPost>(
      ApiUrls.withParams(ApiUrls.postUpdate, {'id': postId}),
      method: Method.put,
      body: request.toJson(),
      parse: UserPost.fromJson,
    );
  }

  /// Remove um post (`DELETE /api/v1/post/:id`).
  static Future<void> deletePost(String postId) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.postDelete, {'id': postId}),
      method: Method.delete,
    );
  }

  /// Busca um post pelo id (`GET /api/v1/post/:id`).
  static Future<UserPost> getPostById(String postId) {
    return HttpService.request<UserPost>(
      ApiUrls.withParams(ApiUrls.postGet, {'id': postId}),
      parse: UserPost.fromJson,
    );
  }

  /// Lista posts do usuário autenticado (`GET /api/v1/profile/posts`).
  static Future<List<UserPost>> getMyPosts() async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.profileMyPosts,
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['posts'] as List? ?? const [])
        UserPost.fromJson(item),
    ];
  }
}
