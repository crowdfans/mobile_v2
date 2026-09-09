import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip de filtro (período / tipo) nos insights.
class AnalyticsFilterChip extends StatelessWidget {
  const AnalyticsFilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? colors.primary : colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? colors.buttonPrimaryText : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
