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
    this.onPressShare,
    this.onVoteApplied,
  });

  final FeedPost post;
  final bool unlocked;
  final VoidCallback? onPressUnlock;
  final ValueChanged<String>? onPressOpenComments;
  final VoidCallback? onPressOpenProfile;
  final VoidCallback? onPressOptions;
  final VoidCallback? onPressShare;
  final ValueChanged<VoteResult>? onVoteApplied;

  @override
  Widget build(BuildContext context) {
    final resolvedUsername = post.handle.replaceFirst(RegExp(r'^@'), '');
    if (!unlocked) {
      return PostCard(
        post: post,
        hideRank: true,
        onPressOpenProfile: onPressOpenProfile,
        onPressOptions: onPressOptions,
        onPressShare: onPressShare,
        contentOverride: ExclusiveFeedCardLockedContent(
          resolvedUsername: resolvedUsername,
          canUnlock: onPressUnlock != null,
          onPressUnlock: () => onPressUnlock?.call(),
        ),
      );
    }
    // Desbloqueado (Home CF-235): card tintido + badge Exclusivo.
    return PostCard(
      post: post,
      backgroundColor: const Color(0xFFEEF3F8),
      borderColor: const Color(0xFFD7E0EA),
      onPressOpenComments: onPressOpenComments,
      onPressOpenProfile: onPressOpenProfile,
      onPressOptions: onPressOptions,
      onPressShare: onPressShare,
      onVoteApplied: onVoteApplied,
      hideRank: true,
      topContentAfterHeader: false,
      topContent: ExclusivePostMetaRow(
        memberName: resolvedUsername,
        unlocked: true,
      ),
    );
  }
}
