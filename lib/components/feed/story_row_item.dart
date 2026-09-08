import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';

/// Anel de story individual.
class StoryRowItem extends StatelessWidget {
  const StoryRowItem({super.key, required this.story});

  final StoryItem story;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 2),
              ),
              child: PostAvatar(url: story.imageUri, size: 56),
            ),
            const SizedBox(height: 6),
            Text(
              story.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
