import 'package:crowdfans/components/profile/profile_stat_cell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Faixa única de estatísticas do perfil público (Posts / Cartas / Artistas).
class FanProfileStatsRow extends StatelessWidget {
  const FanProfileStatsRow({
    super.key,
    required this.postsCount,
    required this.cardsCount,
    required this.artistsCount,
    this.onArtistsTap,
  });

  final String postsCount;
  final String cardsCount;
  final String artistsCount;
  final VoidCallback? onArtistsTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ProfileStatCell(value: postsCount, label: 'Posts'),
          ProfileStatCell(value: cardsCount, label: 'Cartas', divider: true),
          ProfileStatCell(
            value: artistsCount,
            label: 'Artistas',
            divider: true,
            onTap: onArtistsTap,
          ),
        ],
      ),
    );
  }
}
