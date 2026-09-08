import 'package:crowdfans/components/home/vote_control.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Card padrão de post do feed.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final media =
        post.imageUri ??
        (post.carouselUris.isNotEmpty ? post.carouselUris.first : null) ??
        post.videoThumbnailUri;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PostAvatar(url: post.avatarUri),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${post.handle} · ${post.minutesAgo} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (post.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                post.text,
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
              ),
            ),
          if (media != null && media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  media,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              VoteControl(post: post),
              const Spacer(),
              Icon(Icons.mode_comment_outlined, size: 18, color: colors.icon),
              const SizedBox(width: 4),
              Text(
                '${post.comments}',
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
