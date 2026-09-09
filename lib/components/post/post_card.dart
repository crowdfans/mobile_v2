import 'package:crowdfans/components/home/vote_control.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/components/post/post_media.dart';
import 'package:crowdfans/components/post/post_rank_badge.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/utils/relative_time.dart';
import 'package:flutter/material.dart';

/// Card padrão de post do feed.
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final rank = post.rank?.trim() ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? colors.border),
        color: backgroundColor ?? colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topContent != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: topContent,
            ),
          GestureDetector(
            onTap: onPressOpenProfile,
            child: Row(
              children: [
                PostAvatar(url: post.avatarUri),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              post.handle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                          if (rank.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            PostRankBadge(rank: rank),
                          ],
                        ],
                      ),
                      Text(
                        formatMinutesAgo(post.minutesAgo),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onPressOptions != null)
                  IconButton(
                    key: const Key('post-more'),
                    onPressed: onPressOptions,
                    icon: Icon(Icons.more_horiz, color: colors.icon),
                    tooltip: 'Opções do post',
                  ),
              ],
            ),
          ),
          if (contentOverride != null)
            contentOverride!
          else ...[
            if (post.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  post.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            PostMedia(post: post),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              VoteControl(post: post, onVoteApplied: onVoteApplied),
              const Spacer(),
              GestureDetector(
                key: const Key('post-comments'),
                onTap: onPressOpenComments == null
                    ? null
                    : () => onPressOpenComments!(post.id),
                child: Row(
                  children: [
                    Icon(
                      Icons.mode_comment_outlined,
                      size: 18,
                      color: colors.icon,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.comments}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                key: const Key('post-share'),
                onTap: onPressShare,
                child: Row(
                  children: [
                    Icon(Icons.send_outlined, size: 18, color: colors.icon),
                    const SizedBox(width: 4),
                    Text(
                      '${post.shares}',
                      style: TextStyle(color: colors.textSecondary),
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
