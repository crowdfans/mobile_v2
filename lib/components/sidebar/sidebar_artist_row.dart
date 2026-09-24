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
    final name = artist.username.trim().isEmpty ? 'Artista' : artist.username;
    final starLabel = isFavorite
        ? 'Remover $name dos favoritos'
        : 'Adicionar $name aos favoritos';
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: name,
              child: InkWell(
                onTap: onPressed,
                child: Row(
                  children: [
                    ClipOval(
                      child: avatar.isEmpty
                          ? ColoredBox(
                              color: colors.surface,
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: colors.textTertiary,
                                ),
                              ),
                            )
                          : Image.network(
                              avatar,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => ColoredBox(
                                color: colors.surface,
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        name,
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
          ),
          Semantics(
            button: true,
            label: starLabel,
            toggled: isFavorite,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: starLabel,
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                size: 24,
                color: isFavorite ? AppPalette.yellow500 : colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
