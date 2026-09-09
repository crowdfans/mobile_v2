import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Linhas de breakdown do Fan Score.
class FanScoreBreakdownView extends StatelessWidget {
  const FanScoreBreakdownView({
    super.key,
    required this.breakdown,
    this.deltaPercentage,
  });

  final FanScoreBreakdown breakdown;
  final int? deltaPercentage;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final delta = deltaPercentage;
    final rows = <(String, String)>[
      ('Membership ativa', breakdown.hasMembership ? 'Sim' : 'Não'),
      ('Comentários', '${breakdown.commentsMade}'),
      ('Votos', '${breakdown.upvotesMade}'),
      ('Fan Letters', '${breakdown.fanLettersPosted}'),
      ('Participações em live', '${breakdown.liveParticipations}'),
      ('Doações em live', '${breakdown.liveDonations}'),
      ('Posts no Fã Clube', '${breakdown.fanClubPosts}'),
      if (delta != null)
        (
          'Variação no ciclo',
          '${delta >= 0 ? '+' : ''}$delta%',
        ),
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row.$1,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                Text(
                  row.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
