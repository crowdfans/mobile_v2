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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppPalette.green500, AppPalette.platinum950]
                      : [AppPalette.green100, AppPalette.green500],
                ),
              ),
              child: PostAvatar(url: imageUri, size: 56),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
