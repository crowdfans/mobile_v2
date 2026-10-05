import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/components/feed/exclusive_post_meta_row.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Username no copy “Assine o membership de …” (print CF-175).
/// Remove `@` e prefixo `artist/` — o app antigo mostrava `artist/gusart`.
String exclusiveMembershipUsername(String handle) {
  var value = handle.trim();
  if (value.isEmpty) {
    return 'artista';
  }
  value = value.replaceFirst(RegExp(r'^@'), '');
  value = value.replaceFirst(RegExp(r'^artist/', caseSensitive: false), '');
  value = value.trim();
  return value.isEmpty ? 'artista' : value;
}

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
    final resolvedUsername = exclusiveMembershipUsername(post.handle);
    if (!unlocked) {
      // CF-175: sem tint lilás externo — só o card interno de bloqueio.
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
    // Desbloqueado (Home CF-235): badge Exclusivo acima + rank do print (#3).
    return PostCard(
      post: post,
      backgroundColor: const Color(0xFFEEF3F8),
      borderColor: const Color(0xFFD7E0EA),
      onPressOpenComments: onPressOpenComments,
      onPressOpenProfile: onPressOpenProfile,
      onPressOptions: onPressOptions,
      onPressShare: onPressShare,
      onVoteApplied: onVoteApplied,
      hideRank: false,
      topContentAfterHeader: false,
      topContent: ExclusivePostMetaRow(
        memberName: resolvedUsername,
        unlocked: true,
      ),
    );
  }
}
