import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Layout da linha de ranking.
///
/// - [avatarLeading]: busca home (CF-172) — foto → #/tendência → nome.
/// - [rankLeading]: página Top 100/500 (CF-193 / CF-189) — # → tendência → foto → nome.
enum SearchArtistRankRowLayout { avatarLeading, rankLeading }

/// Linha de artista no ranking.
class SearchArtistRankRow extends StatelessWidget {
  const SearchArtistRankRow({
    super.key,
    required this.artist,
    required this.onPressed,
    this.onPressMore,
    this.position,
    this.metricHint,
    this.layout = SearchArtistRankRowLayout.avatarLeading,
  });

  final ArtistSearchItem artist;
  final VoidCallback onPressed;
  final VoidCallback? onPressMore;
  final int? position;
  final String? metricHint;
  final SearchArtistRankRowLayout layout;

  SearchRankTrend trendFor() {
    return searchRankTrendFromArtist(artist);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final meta = artist.rankingValueLabel?.isNotEmpty == true
        ? artist.rankingValueLabel!
        : (artist.membersLabel.isEmpty ? artist.handle : artist.membersLabel);
    final pos = position ?? artist.rank;
    final showRank = pos != null && pos > 0;
    final hint = (metricHint ?? '').trim();
    final trend = trendFor();
    final semanticsLabel = [
      if (showRank) 'Posição $pos',
      artist.name,
      meta,
      if (hint.isNotEmpty) hint,
      'tendência ${searchRankTrendLabel(trend)}',
    ].join('. ');

    final avatar = _RankAvatar(url: artist.avatarUri.trim(), colors: colors);
    final badge = showRank ? _RankBadge(position: pos!, colors: colors) : null;
    // Print Top 100/500: só o círculo, sem rótulo "estável/subiu".
    final trendDot = SearchRankTrendDot(trend: trend, showLabel: false);
    final info = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
    final more = onPressMore == null
        ? null
        : IconButton(
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
          );

    final List<Widget> children;
    switch (layout) {
      case SearchArtistRankRowLayout.rankLeading:
        // Print CF-193/189: #badge | tendência | avatar | nome/meta | ⋮
        children = [
          if (badge != null) ...[badge, const SizedBox(width: 8)],
          trendDot,
          const SizedBox(width: 10),
          avatar,
          const SizedBox(width: 12),
          info,
          if (more != null) more,
        ];
      case SearchArtistRankRowLayout.avatarLeading:
        // Print CF-172: avatar | (# + tendência acima do nome) | nome/meta | ⋮
        children = [
          avatar,
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
                        _RankBadge(position: pos!, colors: colors),
                        const SizedBox(width: 8),
                        trendDot,
                      ],
                    ),
                  ),
                Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (more != null) more,
        ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.position, required this.colors});

  final int position;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$position',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

class _RankAvatar extends StatelessWidget {
  const _RankAvatar({required this.url, required this.colors});

  final String url;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
    );
  }
}
