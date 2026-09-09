import 'package:crowdfans/components/post/post_card_avatar_column.dart';
import 'package:crowdfans/components/post/post_card_footer.dart';
import 'package:crowdfans/components/post/post_card_header.dart';
import 'package:crowdfans/components/post/post_media.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Card padrão de post do feed (layout PDF: avatar + coluna principal).
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.contentOverride,
    this.topContent,
    this.backgroundColor,
    this.borderColor,
    this.onPressOpenComments,
    this.onPressOpenProfile,
    this.onPressOptions,
    this.onPressShare,
    this.onVoteApplied,
    this.membershipBadges,
    this.isSecretMode = false,
  });

  final FeedPost post;
  final Widget? contentOverride;
  final Widget? topContent;
  final Color? backgroundColor;
  final Color? borderColor;
  final ValueChanged<String>? onPressOpenComments;
  final VoidCallback? onPressOpenProfile;
  final VoidCallback? onPressOptions;
  final VoidCallback? onPressShare;
  final ValueChanged<VoteResult>? onVoteApplied;
  final List<MembershipBadgeInfo>? membershipBadges;
  final bool isSecretMode;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final displayAuthorName =
        (post.clubArtistName ?? '').trim().isNotEmpty
        ? post.clubArtistName!.trim()
        : post.author;
    final badges = membershipBadges ?? post.membershipBadges;
    final showSecret = isSecretMode || post.isSecret;
    final isMembershipLocked =
        post.membershipLocked || post.exclusiveLocked;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        color: backgroundColor ?? colors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topContent != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: topContent,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCardAvatarColumn(
                post: post,
                onPressOpenProfile: onPressOpenProfile,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostCardHeader(
                      displayAuthorName: displayAuthorName,
                      displayAuthorHandle: post.handle,
                      rank: post.rank,
                      minutesAgo: post.minutesAgo,
                      membershipBadges: badges,
                      showSecretBadge: showSecret,
                      onPressOpenProfile: onPressOpenProfile,
                      onPressOpenPostOptions: onPressOptions,
                    ),
                    if (contentOverride != null)
                      contentOverride!
                    else ...[
                      if (post.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 4),
                          child: GestureDetector(
                            onTap: onPressOpenComments == null
                                ? null
                                : () => onPressOpenComments!(post.id),
                            child: Text(
                              post.text,
                              style: TextStyle(
                                fontSize: 16,
                                height: 24 / 16,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      PostMedia(post: post),
                      if (post.type == PostType.membership &&
                          isMembershipLocked)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Disponível para membros deste perfil.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                    ],
                    PostCardFooter(
                      post: post,
                      onOpenComments: onPressOpenComments == null
                          ? null
                          : () => onPressOpenComments!(post.id),
                      onOpenShare: onPressShare,
                      onVoteApplied: onVoteApplied,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
