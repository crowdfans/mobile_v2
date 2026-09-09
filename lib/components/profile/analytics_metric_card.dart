import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_analytics_service.dart';
import 'package:flutter/material.dart';

/// Cartão de métrica 2 colunas.
class AnalyticsMetricCard extends StatelessWidget {
  const AnalyticsMetricCard({
    super.key,
    required this.card,
    this.fullWidth = false,
  });

  final ArtistAnalyticsMetricCard card;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.formattedValue,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                card.label,
                style: TextStyle(fontSize: 12, color: colors.textPrimary),
              ),
              Text(
                card.helper,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
