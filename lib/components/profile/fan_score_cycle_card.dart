import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Cartão do ciclo atual no Fan Score público.
class FanScoreCycleCard extends StatelessWidget {
  const FanScoreCycleCard({super.key, required this.details});

  final FanScoreCycleDetails details;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ciclo ${details.cycleLabel ?? ''}'.trim(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if ((details.endLabel ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Encerra em ${details.endLabel}',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ],
            if ((details.helperText ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                details.helperText!,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
