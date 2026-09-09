import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';

/// Linha de artista no ranking Top 500 (badge + tendência + avatar quadrado).
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

  SearchRankTrend trendFor(int pos) {
    final delta = artist.rankDelta;
    if (delta == null) {
      return SearchRankTrend.flat;
    }
    if (delta > 0) {
      return SearchRankTrend.up;
    }
    if (delta < 0) {
      return SearchRankTrend.down;
    }
    return SearchRankTrend.flat;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final meta = artist.rankingValueLabel?.isNotEmpty == true
        ? artist.rankingValueLabel!
        : (artist.membersLabel.isEmpty ? artist.handle : artist.membersLabel);
    final pos = position ?? artist.rank ?? 0;
    final url = artist.avatarUri.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
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
            const SizedBox(width: 8),
            SearchRankTrendDot(trend: trendFor(pos)),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url.isEmpty
                  ? ColoredBox(
                      color: colors.surfaceAlt,
                      child: const SizedBox(width: 48, height: 48),
                    )
                  : Image.network(
                      url,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: colors.surfaceAlt,
                        child: const SizedBox(width: 48, height: 48),
                      ),
                    ),
            ),
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
            if (onPressMore != null)
              IconButton(
                onPressed: onPressMore,
                icon: Icon(Icons.more_vert, color: colors.icon),
                tooltip: 'Opções do artista',
              ),
          ],
        ),
      ),
    );
  }
}
