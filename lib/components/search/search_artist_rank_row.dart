import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Linha de artista no ranking Top 500 (foto à esquerda; posição/tendência acima do nome).
class SearchArtistRankRow extends StatelessWidget {
  const SearchArtistRankRow({
    super.key,
    required this.artist,
    required this.onPressed,
    this.onPressMore,
    this.position,
    this.metricHint,
  });

  final ArtistSearchItem artist;
  final VoidCallback onPressed;
  final VoidCallback? onPressMore;
  final int? position;
  final String? metricHint;

  SearchRankTrend trendFor() {
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

  String trendLabel() {
    return switch (trendFor()) {
      SearchRankTrend.up => 'subiu',
      SearchRankTrend.down => 'desceu',
      SearchRankTrend.flat => 'estável',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final meta = artist.rankingValueLabel?.isNotEmpty == true
        ? artist.rankingValueLabel!
        : (artist.membersLabel.isEmpty ? artist.handle : artist.membersLabel);
    final pos = position ?? artist.rank;
    final showRank = pos != null && pos > 0;
    final url = artist.avatarUri.trim();
    final hint = (metricHint ?? '').trim();
    final semanticsLabel = [
      if (showRank) 'Posição $pos',
      artist.name,
      meta,
      if (hint.isNotEmpty) hint,
      'tendência $trendLabel()',
    ].join('. ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: InkWell(
          onTap: onPressed,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: url.isEmpty
                    ? ColoredBox(
                        color: colors.surfaceAlt,
                        child: const SizedBox(width: 56, height: 56),
                      )
                    : Image.network(
                        url,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: colors.surfaceAlt,
                          child: const SizedBox(width: 56, height: 56),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showRank)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceAlt,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$pos',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SearchRankTrendDot(trend: trendFor()),
                          ],
                        ),
                      ),
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
                  icon: SvgPicture.asset(
                    'assets/icons/General/dots-vertical.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      colors.icon,
                      BlendMode.srcIn,
                    ),
                  ),
                  tooltip: 'Opções de ${artist.name}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
