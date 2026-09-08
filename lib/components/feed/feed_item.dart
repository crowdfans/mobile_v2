import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';

/// Escolhe card exclusivo ou padrão.
class FeedItem extends StatelessWidget {
  const FeedItem({
    super.key,
    required this.post,
    required this.canAccessExclusive,
  });

  final FeedPost post;
  final bool canAccessExclusive;

  @override
  Widget build(BuildContext context) {
    if (isExclusivePost(post)) {
      return ExclusiveFeedCard(
        post: post,
        unlocked: canAccessExclusive || post.exclusiveLocked == false,
      );
    }
    return PostCard(post: post);
  }
}
