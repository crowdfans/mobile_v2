import 'package:crowdfans/components/home/vote_control.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Barra de ações do post: voto à esquerda, comentários e share à direita.
class PostCardFooter extends StatelessWidget {
  const PostCardFooter({
    super.key,
    required this.post,
    this.onOpenComments,
    this.onOpenShare,
    this.onVoteApplied,
  });

  final FeedPost post;
  final VoidCallback? onOpenComments;
  final VoidCallback? onOpenShare;
  final ValueChanged<VoteResult>? onVoteApplied;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          VoteControl(post: post, onVoteApplied: onVoteApplied),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                key: const Key('post-comments'),
                onTap: onOpenComments,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/feed/chat_circle.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        colors.textTertiary,
                        BlendMode.srcIn,
                      ),
                    ),
                    if (post.comments > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${post.comments}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 26),
              GestureDetector(
                key: const Key('post-share'),
                onTap: onOpenShare,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Communication/send-03.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colors.textTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                      if (post.shares > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${post.shares}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
