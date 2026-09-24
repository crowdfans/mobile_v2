import 'package:crowdfans/components/search/search_artist_rank_metric_card.dart';
import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Sheet de detalhes do ranking (métricas agrupadas + Reportar separado).
///
/// Indisponível aparece como "—" — nunca zero inventado (CF-241).
class SearchArtistRankDetailsSheet extends StatelessWidget {
  const SearchArtistRankDetailsSheet({
    super.key,
    required this.visible,
    required this.artist,
    required this.onClose,
  });

  final bool visible;
  final ArtistSearchItem? artist;
  final VoidCallback onClose;

  static const _unavailable = '—';

  void handleReport(BuildContext context) {
    final current = artist;
    onClose();
    if (current == null) {
      return;
    }
    context.push(
      '${Pages.report}?context=artist-profile'
      '&targetId=${Uri.encodeComponent(current.id)}'
      '&displayName=${Uri.encodeComponent(current.name)}',
    );
  }

  String formatPosition(int? value) {
    if (value == null || value <= 0) {
      return _unavailable;
    }
    return '$value';
  }

  String formatWeeks(int? value) {
    if (value == null || value < 0) {
      return _unavailable;
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final current = artist;
    final rank = current?.rank;
    final meta = current?.rankingValueLabel?.isNotEmpty == true
        ? current!.rankingValueLabel!
        : (current?.membersLabel.isNotEmpty == true
              ? current!.membersLabel
              : (current?.handle ?? ''));
    final trend = searchRankTrendFromArtist(current);
    final url = current?.avatarUri.trim() ?? '';

    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                    Row(
                      children: [
                        if (rank != null && rank > 0)
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
                              '#$rank',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        if (rank != null && rank > 0) const SizedBox(width: 8),
                        SearchRankTrendDot(trend: trend, showLabel: false),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      current?.name ?? 'Artista',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchArtistRankMetricCard(
            label: 'Semanas no ranking',
            value: formatWeeks(current?.weeksInRanking),
          ),
          const SizedBox(height: 8),
          SearchArtistRankMetricCard(
            label: 'Posição máxima',
            value: formatPosition(current?.peakRank),
          ),
          const SizedBox(height: 8),
          SearchArtistRankMetricCard(
            label: 'Semana passada',
            value: formatPosition(current?.previousRank),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Reportar ${current?.name ?? 'artista'}',
            child: InkWell(
              onTap: () => handleReport(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Communication/message-alert-circle.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        colors.danger,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reportar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
