import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compartilhamento de post do feed (nativo, WhatsApp e copiar link).
abstract final class PostShareService {
  static String postLink(FeedPost post) =>
      'https://crowdfans.app/posts/${post.id}';

  static String buildPostShareMessage(FeedPost post) {
    final author = post.author.trim().isEmpty
        ? 'Crowdfans'
        : post.author.trim();
    final excerpt = post.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final clipped = excerpt.length > 140 ? excerpt.substring(0, 140) : excerpt;
    final link = postLink(post);
    if (clipped.isNotEmpty) {
      return '$author: $clipped\n$link';
    }
    return 'Post de $author no Crowdfans\n$link';
  }

  static Future<void> copyLink(FeedPost post) {
    return Clipboard.setData(ClipboardData(text: postLink(post)));
  }

  static Future<void> shareFeedPost(FeedPost post) {
    return SharePlus.instance.share(
      ShareParams(
        title: 'Compartilhar post',
        text: buildPostShareMessage(post),
      ),
    );
  }

  static Future<void> shareWhatsApp(FeedPost post) async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(buildPostShareMessage(post))}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      await shareFeedPost(post);
    }
  }

  static Future<void> shareStories(FeedPost post) {
    return shareFeedPost(post);
  }
}
