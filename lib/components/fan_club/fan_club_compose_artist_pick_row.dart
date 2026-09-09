import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha para escolher o artista do post no fã clube.
class FanClubComposeArtistPickRow extends StatelessWidget {
  const FanClubComposeArtistPickRow({
    super.key,
    required this.artist,
    required this.onPressed,
  });

  final FanClubComposeArtist artist;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PostAvatar(url: artist.avatarUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                artist.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
