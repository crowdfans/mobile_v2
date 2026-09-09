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
        width: 98,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 2),
              ),
              child: PostAvatar(url: story.imageUri, size: 84),
            ),
            const SizedBox(height: 8),
            Text(
              story.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
