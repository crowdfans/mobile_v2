import 'package:crowdfans/components/profile/fan_profile_followed_artist_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:flutter/material.dart';

/// Seção horizontal de artistas seguidos no Meu Perfil.
class MeFollowedArtistsSection extends StatelessWidget {
  const MeFollowedArtistsSection({
    super.key,
    required this.artists,
    required this.onSeeAll,
    required this.onPressArtist,
  });

  final List<FollowedArtist> artists;
  final VoidCallback onSeeAll;
  final ValueChanged<FollowedArtist> onPressArtist;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (artists.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = artists.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Artistas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryStrong,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final artist = visible[index];
              return FanProfileFollowedArtistChip(
                artist: artist,
                onTap: () => onPressArtist(artist),
              );
            },
          ),
        ),
      ],
    );
  }
}
