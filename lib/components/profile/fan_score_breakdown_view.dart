import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Linhas de breakdown do Fan Score.
class FanScoreBreakdownView extends StatelessWidget {
  const FanScoreBreakdownView({super.key, required this.breakdown});

  final FanScoreBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final rows = <(String, String)>[
      ('Membership', breakdown.hasMembership ? 'Sim' : 'Não'),
      ('Comentários', '${breakdown.commentsMade}'),
      ('Upvotes', '${breakdown.upvotesMade}'),
      ('Fan letters', '${breakdown.fanLettersPosted}'),
      ('Doações em live', '${breakdown.liveDonations}'),
      ('Participações em live', '${breakdown.liveParticipations}'),
      ('Posts no fan club', '${breakdown.fanClubPosts}'),
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
