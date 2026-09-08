import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:flutter/material.dart';

/// Data relativa curta (`agora`, `5m atrás`, …) para a lista Meus posts.
String formatMyPostDate(String dateString) {
  final date = DateTime.tryParse(dateString);
  if (date == null) {
    return '';
  }
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) {
    return 'agora';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m atrás';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h atrás';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d atrás';
  }
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// Card de um post na lista Meus posts.
class MyPostRow extends StatelessWidget {
  const MyPostRow({super.key, required this.post, required this.onOpenMenu});

  final UserPost post;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postTypeLabel(post.type).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMyPostDate(post.createdAt),
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onOpenMenu,
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
