import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Chip de story com anel verde (Meet).
class StoryMeetAndGreetItem extends StatelessWidget {
  const StoryMeetAndGreetItem({
    super.key,
    required this.artistId,
    required this.name,
    required this.imageUri,
  });

  final String artistId;
  final String name;
  final String imageUri;

  void handleTap(BuildContext context) {
    var id = artistId.trim();
    if (id.startsWith('story-')) {
      id = id.substring('story-'.length);
    }
    if (id.isEmpty) {
      return;
    }
    context.push(
      Pages.meetRequestOf(
        artistId: id,
        name: name,
        avatarUrl: imageUri,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 98,
        child: InkWell(
          onTap: () => handleTap(context),
          borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
