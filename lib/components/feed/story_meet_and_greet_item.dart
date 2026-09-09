import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip de story com anel verde (Meet). Sem navegação — Meet ainda ⛔ no Expo.
class StoryMeetAndGreetItem extends StatelessWidget {
  const StoryMeetAndGreetItem({
    super.key,
    required this.name,
    required this.imageUri,
  });

  final String name;
  final String imageUri;

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
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.green500, width: 3),
              ),
              child: PostAvatar(url: imageUri, size: 78),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
