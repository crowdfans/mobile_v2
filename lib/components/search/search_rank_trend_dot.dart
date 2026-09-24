import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';

enum SearchRankTrend { up, down, flat }

String searchRankTrendLabel(SearchRankTrend trend) {
  return switch (trend) {
    SearchRankTrend.up => 'subiu',
    SearchRankTrend.down => 'desceu',
    SearchRankTrend.flat => 'estável',
  };
}

SearchRankTrend searchRankTrendFromDelta(int? delta) {
  if (delta == null || delta == 0) {
    return SearchRankTrend.flat;
  }
  if (delta > 0) {
    return SearchRankTrend.up;
  }
  return SearchRankTrend.down;
}

/// Prefere o campo `trend` da API (`up`/`down`/…); `trendDelta` é absoluto.
SearchRankTrend searchRankTrendFromArtist(ArtistSearchItem? artist) {
  if (artist == null) {
    return SearchRankTrend.flat;
  }
  switch ((artist.trend ?? '').toLowerCase()) {
    case 'up':
      return SearchRankTrend.up;
    case 'down':
      return SearchRankTrend.down;
    case 'new':
    case 'neutral':
    case 'flat':
      return SearchRankTrend.flat;
  }
  return searchRankTrendFromDelta(artist.rankDelta);
}

/// Indicador de tendência com ícone + texto (não depende só da cor).
class SearchRankTrendDot extends StatelessWidget {
  const SearchRankTrendDot({
    super.key,
    required this.trend,
    this.showLabel = true,
  });

  final SearchRankTrend trend;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final (color, icon) = switch (trend) {
      SearchRankTrend.up => (
        const Color(0xFF22C55E),
        Icons.arrow_upward_rounded,
      ),
      SearchRankTrend.down => (
        const Color(0xFFEF4444),
        Icons.arrow_downward_rounded,
      ),
      SearchRankTrend.flat => (
        const Color(0xFF94A3B8),
        Icons.remove_rounded,
      ),
    };
    final label = searchRankTrendLabel(trend);
    return Semantics(
      label: 'tendência $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
