import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:flutter/material.dart';

/// Chip horizontal de artista seguido no perfil público.
class FanProfileFollowedArtistChip extends StatelessWidget {
  const FanProfileFollowedArtistChip({
    super.key,
    required this.artist,
    required this.onTap,
  });

  final FollowedArtist artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            PostAvatar(url: artist.avatarUri ?? '', size: 56),
            const SizedBox(height: 6),
            Text(
              artist.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
