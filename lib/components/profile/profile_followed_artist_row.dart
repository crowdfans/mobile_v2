import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:flutter/material.dart';

/// Linha da lista de artistas seguidos.
class ProfileFollowedArtistRow extends StatelessWidget {
  const ProfileFollowedArtistRow({super.key, required this.artist, this.onTap});

  final FollowedArtist artist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            PostAvatar(url: artist.avatarUri ?? '', size: 54),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${artist.memberCount} membros',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
