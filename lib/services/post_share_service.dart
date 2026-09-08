import 'package:crowdfans/models/feed_post.dart';
import 'package:share_plus/share_plus.dart';

/// Compartilhamento nativo de post do feed.
abstract final class PostShareService {
  static String buildPostShareMessage(FeedPost post) {
    final author = post.author.trim().isEmpty
        ? 'Crowdfans'
        : post.author.trim();
    final excerpt = post.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final clipped = excerpt.length > 140 ? excerpt.substring(0, 140) : excerpt;
    final link = 'https://crowdfans.app/posts/${post.id}';
    if (clipped.isNotEmpty) {
      return '$author: $clipped\n$link';
    }
    return 'Post de $author no Crowdfans\n$link';
  }

  static Future<void> shareFeedPost(FeedPost post) {
    return SharePlus.instance.share(
      ShareParams(
        title: 'Compartilhar post',
        text: buildPostShareMessage(post),
      ),
    );
  }
}
