import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/components/feed/exclusive_post_meta_row.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Card para posts exclusivos com indicação visual de bloqueio.
class ExclusiveFeedCard extends StatelessWidget {
  const ExclusiveFeedCard({
    super.key,
    required this.post,
    required this.unlocked,
    this.onPressUnlock,
    this.onPressOpenComments,
    this.onPressOpenProfile,
    this.onPressOptions,
    this.onVoteApplied,
  });

  final FeedPost post;
  final bool unlocked;
  final VoidCallback? onPressUnlock;
  final ValueChanged<String>? onPressOpenComments;
  final VoidCallback? onPressOpenProfile;
  final VoidCallback? onPressOptions;
  final ValueChanged<VoteResult>? onVoteApplied;

  @override
  Widget build(BuildContext context) {
    final resolvedUsername = post.handle.replaceFirst(RegExp(r'^@'), '');
    if (!unlocked) {
      return PostCard(
        post: post,
        onPressOpenProfile: onPressOpenProfile,
        onPressOptions: onPressOptions,
        contentOverride: ExclusiveFeedCardLockedContent(
          resolvedUsername: resolvedUsername,
          canUnlock: onPressUnlock != null,
          onPressUnlock: () => onPressUnlock?.call(),
        ),
      );
    }
    return PostCard(
      post: post,
      onPressOpenComments: onPressOpenComments,
      onPressOpenProfile: onPressOpenProfile,
      onPressOptions: onPressOptions,
      onVoteApplied: onVoteApplied,
      topContent: ExclusivePostMetaRow(
        memberName: resolvedUsername,
        unlocked: true,
      ),
    );
  }
}
