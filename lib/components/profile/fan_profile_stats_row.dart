import 'package:crowdfans/components/profile/fan_profile_stat_card.dart';
import 'package:flutter/material.dart';

/// Três cartões de estatística do perfil público.
class FanProfileStatsRow extends StatelessWidget {
  const FanProfileStatsRow({
    super.key,
    required this.postsCount,
    required this.cardsCount,
    required this.artistsCount,
  });

  final String postsCount;
  final String cardsCount;
  final String artistsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FanProfileStatCard(value: postsCount, label: 'Posts'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FanProfileStatCard(value: cardsCount, label: 'Memberships'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FanProfileStatCard(value: artistsCount, label: 'Artistas'),
        ),
      ],
    );
  }
}
