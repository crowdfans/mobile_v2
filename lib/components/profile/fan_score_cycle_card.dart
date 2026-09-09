import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Cartão do ciclo vigente no FanScore (mock Fanscore).
class FanScoreCycleCard extends StatelessWidget {
  const FanScoreCycleCard({super.key, required this.details});

  final FanScoreCycleDetails details;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final period =
        (details.periodLabel ?? details.cycleLabel ?? '').trim();
    final title = period.isEmpty
        ? 'Pontuação vigente'
        : 'Pontuação vigente: $period';
    final endLabel = (details.endLabel ?? '').trim();
    final body = endLabel.isNotEmpty
        ? 'O ciclo vigente encerra em $endLabel e reseta logo em seguida.'
        : (details.helperText ?? '').trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                body,
                style: TextStyle(
                  fontSize: 13,
                  height: 18 / 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
