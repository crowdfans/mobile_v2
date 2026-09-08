import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Direção do voto: +1 upvote, -1 downvote.
typedef VoteDirection = int;

/// Resultado persistido pelo backend.
class VoteResult {
  const VoteResult({
    required this.id,
    required this.votes,
    required this.myVote,
  });

  final String id;
  final int votes;
  final int myVote;

  factory VoteResult.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return VoteResult(
      id: map['id'] as String? ?? '',
      votes: (map['votes'] as num?)?.toInt() ?? 0,
      myVote: (map['myVote'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Votos em post e comentário (`POST /api/v1/posts/:id/vote`).
abstract final class VoteService {
  static int normalizeVoteState(int? value) {
    if (value == 1 || value == -1) {
      return value!;
    }
    return 0;
  }

  static ({int nextVoteState, int voteCountDelta}) getNextVoteState({
    required int currentState,
    required VoteDirection direction,
  }) {
    if (direction == 1) {
      if (currentState == 1) {
        return (nextVoteState: 0, voteCountDelta: -1);
      }
      if (currentState == -1) {
        return (nextVoteState: 1, voteCountDelta: 2);
      }
      return (nextVoteState: 1, voteCountDelta: 1);
    }
    if (currentState == -1) {
      return (nextVoteState: 0, voteCountDelta: 1);
    }
    if (currentState == 1) {
      return (nextVoteState: -1, voteCountDelta: -2);
    }
    return (nextVoteState: -1, voteCountDelta: -1);
  }

  static Future<VoteResult> votePost(String postId, VoteDirection direction) {
    return HttpService.request<VoteResult>(
      ApiUrls.withParams(ApiUrls.postVote, {'postId': postId}),
      method: Method.post,
      body: {'direction': direction},
      parse: VoteResult.fromJson,
    );
  }

  static Future<VoteResult> voteComment(
    String commentId,
    VoteDirection direction,
  ) {
    return HttpService.request<VoteResult>(
      ApiUrls.withParams(ApiUrls.commentVote, {'commentId': commentId}),
      method: Method.post,
      body: {'direction': direction},
      parse: VoteResult.fromJson,
    );
  }
}
