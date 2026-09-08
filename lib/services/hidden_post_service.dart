import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Post ocultado pelo viewer.
class HiddenPost {
  const HiddenPost({
    required this.postId,
    required this.authorName,
    required this.authorHandle,
    required this.excerpt,
    required this.hiddenAt,
    this.imageUrl,
  });

  final String postId;
  final String authorName;
  final String authorHandle;
  final String excerpt;
  final String? imageUrl;
  final String hiddenAt;

  factory HiddenPost.fromJson(Map<String, dynamic> json) {
    return HiddenPost(
      postId: json['postId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorHandle: json['authorHandle'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      hiddenAt: json['hiddenAt'] as String? ?? '',
    );
  }
}

/// Ocultar / listar posts (`/api/v1/hidden-posts`).
abstract final class HiddenPostService {
  static Future<List<HiddenPost>> listHiddenPosts() async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.hiddenPosts,
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['posts'] as List? ?? const [])
        HiddenPost.fromJson(item as Map<String, dynamic>),
    ];
  }

  static Future<void> hidePost(String postId) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.hiddenPost, {'postId': postId}),
      method: Method.post,
    );
  }

  static Future<void> unhidePost(String postId) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.hiddenPost, {'postId': postId}),
      method: Method.delete,
    );
  }
}
