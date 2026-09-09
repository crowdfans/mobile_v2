import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_analytics_service.dart';
import 'package:flutter/material.dart';

/// Seção "Que tipo de ação puxou resultado" com barras horizontais.
class AnalyticsBreakdownSection extends StatelessWidget {
  const AnalyticsBreakdownSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final List<ArtistAnalyticsBreakdownRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxValue = rows.fold<num>(1, (current, row) {
      return row.value > current ? row.value : current;
    });
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
            for (final row in rows) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    formatCompactPtBr(row.value),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (row.value / maxValue).clamp(0.04, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: colors.surfaceAlt,
                  color: colors.primary,
                ),
              ),
              if (row.helper.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  row.helper,
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
