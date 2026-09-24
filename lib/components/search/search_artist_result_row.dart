import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';

/// Linha de resultado da busca de artistas (foto, nome, @, membros, #rank).
class SearchArtistResultRow extends StatelessWidget {
  const SearchArtistResultRow({
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
    final handle = artist.handle.trim().isEmpty
        ? ''
        : (artist.handle.startsWith('@')
            ? artist.handle
            : '@${artist.handle}');
    final members = artist.membersLabel.isNotEmpty
        ? artist.membersLabel
        : (artist.memberCount > 0 ? '${artist.memberCount} membros' : '');
    final pos = position ?? artist.rank;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                PostAvatar(url: artist.avatarUri, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (handle.isNotEmpty)
                        Text(
                          handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      if (members.isNotEmpty)
                        Text(
                          members,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (pos != null && pos > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          colors.surfaceAlt,
                          colors.border.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                    child: Text(
                      '#$pos',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
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
