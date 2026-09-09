import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/components/feed/exclusive_post_meta_row.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/constants/theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? AppPalette.purple950 : AppPalette.purple50;
    final border = isDark ? AppPalette.purple800 : AppPalette.purple200;
    final resolvedUsername = post.handle.replaceFirst(RegExp(r'^@'), '');
    if (!unlocked) {
      return PostCard(
        post: post,
        backgroundColor: tint,
        borderColor: border,
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
    return PostCard(
      post: post,
      backgroundColor: tint,
      borderColor: border,
      onPressOpenComments: onPressOpenComments,
      onPressOpenProfile: onPressOpenProfile,
      onPressOptions: onPressOptions,
      onPressShare: onPressShare,
      onVoteApplied: onVoteApplied,
      topContent: ExclusivePostMetaRow(
        memberName: resolvedUsername,
        unlocked: true,
      ),
    );
  }
}
