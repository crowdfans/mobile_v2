import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';

/// Linha de artista no ranking / busca.
class SearchArtistRankRow extends StatelessWidget {
  const SearchArtistRankRow({
    super.key,
    required this.artist,
    required this.onPressed,
    this.onPressMore,
    this.position,
  });

  final ArtistSearchItem artist;
  final VoidCallback onPressed;
  final VoidCallback? onPressMore;
  final int? position;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final meta = artist.rankingValueLabel?.isNotEmpty == true
        ? artist.rankingValueLabel!
        : (artist.membersLabel.isEmpty ? artist.handle : artist.membersLabel);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.border),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                PostAvatar(url: artist.avatarUri, size: 48),
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
                      Text(
                        meta,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (position != null)
                  Text(
                    '#$position',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                if (onPressMore != null)
                  IconButton(
                    onPressed: onPressMore,
                    icon: Icon(Icons.more_vert, color: colors.icon),
                    tooltip: 'Opções do artista',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
