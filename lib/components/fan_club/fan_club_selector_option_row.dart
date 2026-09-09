import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha do dropdown de fã clube com rádio à direita.
class FanClubSelectorOptionRow extends StatelessWidget {
  const FanClubSelectorOptionRow({
    super.key,
    required this.artist,
    required this.selected,
    required this.onPressed,
  });

  final FanClubComposeArtist artist;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            PostAvatar(url: artist.avatarUrl, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                artist.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.primary : colors.border,
                  width: selected ? 6 : 1.5,
                ),
              ),
              child: const SizedBox(width: 20, height: 20),
            ),
          ],
        ),
      ),
    );
  }
}
