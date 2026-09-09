import 'package:crowdfans/components/profile/fan_score_breakdown_metric.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Grade de métricas do breakdown (mock Fanscore expandido).
class FanScoreBreakdownView extends StatelessWidget {
  const FanScoreBreakdownView({
    super.key,
    required this.breakdown,
    this.deltaPercentage,
  });

  final FanScoreBreakdown breakdown;

  /// Mantido por compatibilidade com o cartão de artista.
  final int? deltaPercentage;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, String)>[
      ('${breakdown.fanClubPosts}', 'Posts FC'),
      ('${breakdown.fanLettersPosted}', 'Cartas'),
      ('${breakdown.commentsMade}', 'Coment.'),
      ('${breakdown.upvotesMade}', 'Upvotes'),
      ('${breakdown.liveParticipations}', 'Lives'),
      ('${breakdown.liveDonations}', 'Doações'),
      (breakdown.hasMembership ? '1' : '0', 'Membership'),
    ];
    // deltaPercentage não entra na grade — o mock mostra delta na linha de score.
    return Column(
      children: [
        Row(
          children: [
            for (final metric in metrics.take(4))
              Expanded(
                child: FanScoreBreakdownMetric(
                  value: metric.$1,
                  label: metric.$2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final metric in metrics.skip(4))
              Expanded(
                child: FanScoreBreakdownMetric(
                  value: metric.$1,
                  label: metric.$2,
                ),
              ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }
}
