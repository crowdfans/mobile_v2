import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Card de post exclusivo (conteúdo bloqueado ou liberado).
class ExclusiveFeedCard extends StatelessWidget {
  const ExclusiveFeedCard({
    super.key,
    required this.post,
    required this.unlocked,
  });

  final FeedPost post;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    if (unlocked) {
      return PostCard(post: post);
    }
    final colors = CrowdFansTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceAlt,
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: colors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              'Conteúdo exclusivo de ${post.author}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Assine o membership para ver',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
