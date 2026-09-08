import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Comentário de um post (`GET /api/v1/posts/:postId/comments`).
class CommentItem {
  const CommentItem({
    required this.id,
    required this.author,
    required this.handle,
    required this.avatarUri,
    required this.minutesAgo,
    required this.text,
    required this.votes,
    this.gifUrl,
    this.myVote = 0,
    this.parentCommentId,
    this.replies = const [],
  });

  final String id;
  final String author;
  final String handle;
  final String avatarUri;
  final int minutesAgo;
  final String text;
  final String? gifUrl;
  final int votes;
  final int myVote;
  final String? parentCommentId;
  final List<CommentItem> replies;

  CommentItem copyWith({
    String? text,
    String? gifUrl,
    int? votes,
    int? myVote,
    List<CommentItem>? replies,
    bool clearGif = false,
  }) {
    return CommentItem(
      id: id,
      author: author,
      handle: handle,
      avatarUri: avatarUri,
      minutesAgo: minutesAgo,
      text: text ?? this.text,
      gifUrl: clearGif ? null : (gifUrl ?? this.gifUrl),
      votes: votes ?? this.votes,
      myVote: myVote ?? this.myVote,
      parentCommentId: parentCommentId,
      replies: replies ?? this.replies,
    );
  }

  factory CommentItem.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return CommentItem(
      id: map['id'] as String? ?? '',
      author: map['author'] as String? ?? '',
      handle: map['handle'] as String? ?? '',
      avatarUri: map['avatarUri'] as String? ?? '',
      minutesAgo: (map['minutesAgo'] as num?)?.toInt() ?? 0,
      text: map['text'] as String? ?? map['content'] as String? ?? '',
      gifUrl: map['gifUrl'] as String?,
      votes: (map['votes'] as num?)?.toInt() ?? 0,
      myVote: (map['myVote'] as num?)?.toInt() ?? 0,
      parentCommentId: map['parentCommentId'] as String?,
      replies: [
        for (final item in map['replies'] as List? ?? const [])
          CommentItem.fromJson(item),
      ],
    );
  }
}

/// Página de comentários.
class CommentsPage {
  const CommentsPage({
    required this.comments,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<CommentItem> comments;
  final int totalCount;
  final int page;
  final int pageSize;

  factory CommentsPage.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    final list = map['data'] as List? ?? map['comments'] as List? ?? const [];
    return CommentsPage(
      comments: [for (final item in list) CommentItem.fromJson(item)],
      totalCount: (map['totalCount'] as num?)?.toInt() ?? 0,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }
}

/// CRUD de comentários.
abstract final class CommentService {
  /// Lista comentários de um post.
  static Future<CommentsPage> getCommentsByPostId(
    String postId, {
    int page = 1,
    int pageSize = 20,
  }) {
    final query = Uri(
      queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
    );
    return HttpService.request<CommentsPage>(
      '${ApiUrls.withParams(ApiUrls.postComments, {'postId': postId})}?${query.query}',
      parse: CommentsPage.fromJson,
    );
  }

  /// Cria um comentário (ou resposta).
  static Future<CommentItem> createComment({
    required String postId,
    required String content,
    String? gifUrl,
    String? parentCommentId,
  }) {
    return HttpService.request<CommentItem>(
      ApiUrls.withParams(ApiUrls.postComments, {'postId': postId}),
      method: Method.post,
      body: {
        'content': content,
        if (gifUrl != null && gifUrl.isNotEmpty) 'gifUrl': gifUrl,
        if (parentCommentId != null && parentCommentId.isNotEmpty)
          'parentCommentId': parentCommentId,
      },
      parse: CommentItem.fromJson,
    );
  }

  /// Atualiza um comentário próprio.
  static Future<CommentItem> updateComment({
    required String commentId,
    required String content,
    String? gifUrl,
  }) {
    return HttpService.request<CommentItem>(
      ApiUrls.withParams(ApiUrls.commentUpdate, {'commentId': commentId}),
      method: Method.put,
      body: {
        'content': content,
        if (gifUrl != null && gifUrl.isNotEmpty) 'gifUrl': gifUrl,
      },
      parse: CommentItem.fromJson,
    );
  }

  /// Remove um comentário próprio.
  static Future<void> deleteComment(String commentId) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.commentDelete, {'commentId': commentId}),
      method: Method.delete,
    );
  }
}
