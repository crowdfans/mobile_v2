import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';

/// Linha da sidebar: avatar, username e estrela de favorito.
class SidebarArtistRow extends StatelessWidget {
  const SidebarArtistRow({
    super.key,
    required this.artist,
    required this.isFavorite,
    required this.onPressed,
    required this.onToggleFavorite,
  });

  final HomeFollowedArtist artist;
  final bool isFavorite;
  final VoidCallback onPressed;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final avatar = artist.avatarUrl.trim();
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: Row(
                children: [
                  ClipOval(
                    child: avatar.isEmpty
                        ? ColoredBox(
                            color: colors.surface,
                            child: const SizedBox(width: 24, height: 24),
                          )
                        : Image.network(
                            avatar,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      artist.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onToggleFavorite,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 24,
              color: isFavorite ? AppPalette.yellow500 : colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
