import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card do artista selecionado no compose do fã clube.
class FanClubComposeArtistCard extends StatelessWidget {
  const FanClubComposeArtistCard({
    super.key,
    required this.artist,
    this.onChange,
  });

  final FanClubComposeArtist artist;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PostAvatar(url: artist.avatarUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Publicando no fã clube',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            if (onChange != null)
              TextButton(onPressed: onChange, child: const Text('Trocar')),
          ],
        ),
      ),
    );
  }
}
