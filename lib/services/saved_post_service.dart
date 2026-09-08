import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Post salvo nas memórias.
class SavedPost {
  const SavedPost({
    required this.postId,
    required this.authorName,
    required this.authorHandle,
    required this.text,
    required this.type,
    required this.votes,
    required this.comments,
    required this.savedAt,
    this.imageUrl,
  });

  final String postId;
  final String authorName;
  final String authorHandle;
  final String text;
  final String? imageUrl;
  final String type;
  final int votes;
  final int comments;
  final String savedAt;

  factory SavedPost.fromJson(Map<String, dynamic> json) {
    return SavedPost(
      postId: json['postId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorHandle: json['authorHandle'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String? ?? '',
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      savedAt: json['savedAt'] as String? ?? '',
    );
  }
}

/// Memórias (`/api/v1/saved-posts`).
abstract final class SavedPostService {
  static Future<List<SavedPost>> listSavedPosts() async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.savedPosts,
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['posts'] as List? ?? const [])
        SavedPost.fromJson(item as Map<String, dynamic>),
    ];
  }

  static Future<void> savePost(String postId) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.savedPost, {'postId': postId}),
      method: Method.post,
    );
  }

  static Future<void> unsavePost(String postId) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.savedPost, {'postId': postId}),
      method: Method.delete,
    );
  }
}
