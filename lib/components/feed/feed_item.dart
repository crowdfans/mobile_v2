import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Escolhe card exclusivo ou padrão.
class FeedItem extends StatelessWidget {
  const FeedItem({
    super.key,
    required this.post,
    required this.canAccessExclusive,
    this.onVoteApplied,
    this.onPressOptions,
    this.onPressShare,
    this.onPressUnlock,
    this.clubName,
  });

  final FeedPost post;
  final bool canAccessExclusive;
  final ValueChanged<VoteResult>? onVoteApplied;
  final VoidCallback? onPressOptions;
  final VoidCallback? onPressShare;
  final VoidCallback? onPressUnlock;
  final String? clubName;

  void handleOpenArtist(BuildContext context) {
    final artistId = post.artistId?.trim();
    if (artistId == null || artistId.isEmpty) {
      return;
    }
    context.push(Pages.artistProfile.replaceAll(':artistId', artistId));
  }

  void handleOpenComments(BuildContext context, String postId) {
    context.push(
      Pages.commentsOf(
        postId,
        author: post.author,
        handle: post.handle,
        text: post.text,
        clubName: clubName,
        avatarUrl: post.avatarUri,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isExclusivePost(post)) {
      final unlocked = canAccessExclusive || post.exclusiveLocked == false;
      return ExclusiveFeedCard(
        post: post,
        unlocked: unlocked,
        onPressUnlock: onPressUnlock ?? () => handleOpenArtist(context),
        onPressOpenProfile: () => handleOpenArtist(context),
        onPressOpenComments: unlocked
            ? (postId) => handleOpenComments(context, postId)
            : null,
        onVoteApplied: unlocked ? onVoteApplied : null,
        onPressOptions: onPressOptions,
        onPressShare: onPressShare,
      );
    }
    return PostCard(
      post: post,
      onPressOpenProfile: () => handleOpenArtist(context),
      onPressOpenComments: (postId) => handleOpenComments(context, postId),
      onVoteApplied: onVoteApplied,
      onPressOptions: onPressOptions,
      onPressShare: onPressShare,
    );
  }
}
